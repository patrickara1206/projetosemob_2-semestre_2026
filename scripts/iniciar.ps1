param(
    [string]$FlutterSdk,
    [string]$PythonExecutable,
    [ValidateRange(1024,65535)][int]$ApiPort = 8000,
    [ValidateRange(1024,65535)][int]$WebPort = 8080,
    [ValidateSet('chrome','web-server')][string]$Device = 'chrome',
    [switch]$VerificarBackend
)
$ErrorActionPreference = 'Stop'
$semobRoot = Split-Path $PSScriptRoot -Parent
$semobBackend = Join-Path $semobRoot 'backend'
$semobRuntimeFile = Join-Path $semobRoot '.semob-local\runtime.json'
if (Test-Path -LiteralPath $semobRuntimeFile) {
    $semobRuntime = Get-Content -LiteralPath $semobRuntimeFile -Raw | ConvertFrom-Json
    if (!$FlutterSdk) { $FlutterSdk = $semobRuntime.flutterSdk }
    if (!$PythonExecutable) { $PythonExecutable = $semobRuntime.pythonExecutable }
}
if (!(Test-Path -LiteralPath (Join-Path $semobBackend '.env'))) {
    throw 'Configure backend\.env com SUPABASE_URL e SUPABASE_KEY. Veja backend\.env.example.'
}
if (Get-NetTCPConnection -LocalPort $ApiPort -State Listen -ErrorAction SilentlyContinue) {
    throw "A porta $ApiPort já está em uso. Encerre o backend anterior ou escolha -ApiPort diferente."
}
if (!$VerificarBackend) {
    if (!$FlutterSdk) { $FlutterSdk = $env:FLUTTER_ROOT }
    if ($FlutterSdk) {
        $semobFlutter = Join-Path $FlutterSdk 'bin\flutter.bat'
    } else {
        $semobFlutter = (Get-Command flutter -ErrorAction SilentlyContinue).Source
    }
    if (!$semobFlutter -or !(Test-Path -LiteralPath $semobFlutter)) {
        throw 'Flutter não encontrado. Informe -FlutterSdk "C:\caminho\flutter" ou adicione Flutter ao PATH.'
    }
}
function Invoke-SemobFlutter([string[]]$Arguments) {
    $semobDart = if ($FlutterSdk) { Join-Path $FlutterSdk 'bin\cache\dart-sdk\bin\dart.exe' }
    $semobSnapshot = if ($FlutterSdk) { Join-Path $FlutterSdk 'bin\cache\flutter_tools.snapshot' }
    $semobPlatformEnvironment = @{}
    foreach ($semobFlag in @('FLUTTER_WINDOWS','FLUTTER_LINUX','FLUTTER_MACOS')) {
        $semobPlatformEnvironment[$semobFlag] = [Environment]::GetEnvironmentVariable($semobFlag, 'Process')
        [Environment]::SetEnvironmentVariable($semobFlag, 'false', 'Process')
    }
    try {
        if ($semobDart -and (Test-Path -LiteralPath $semobDart) -and (Test-Path -LiteralPath $semobSnapshot)) {
            & $semobDart $semobSnapshot @Arguments
        } else {
            & $semobFlutter @Arguments
        }
    } finally {
        foreach ($semobFlag in $semobPlatformEnvironment.Keys) {
            [Environment]::SetEnvironmentVariable($semobFlag, $semobPlatformEnvironment[$semobFlag], 'Process')
        }
    }
}
if (!$PythonExecutable) {
    $PythonExecutable = Join-Path $semobRoot '.venv\Scripts\python.exe'
    if (!(Test-Path -LiteralPath $PythonExecutable)) {
        $semobPython = (Get-Command python -ErrorAction Stop).Source
        & $semobPython -m venv (Join-Path $semobRoot '.venv')
        if ($LASTEXITCODE -ne 0) { throw 'Não foi possível criar o ambiente Python.' }
    }
}
try {
    & $PythonExecutable -c 'import fastapi, uvicorn, pandas, supabase, dotenv, multipart, bcrypt, lxml, bs4, html5lib' 2>$null
    $semobDependenciesReady = $LASTEXITCODE -eq 0
} catch { $semobDependenciesReady = $false }
if (!$semobDependenciesReady) {
    & $PythonExecutable -m pip install -r (Join-Path $semobBackend 'requirements.txt')
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao instalar dependências do backend.' }
}
$semobLogs = Join-Path $semobRoot '.semob-local'
New-Item -ItemType Directory -Force -Path $semobLogs | Out-Null
$semobProcess = $null
try {
    $semobProcess = Start-Process -FilePath $PythonExecutable -ArgumentList @(
        '-m','uvicorn','app.main:app','--host','127.0.0.1','--port',"$ApiPort"
    ) -WorkingDirectory $semobBackend -WindowStyle Hidden -PassThru `
      -RedirectStandardOutput (Join-Path $semobLogs 'backend.log') `
      -RedirectStandardError (Join-Path $semobLogs 'backend-errors.log')
    $semobReady = $false
    for ($semobTry = 0; $semobTry -lt 30; $semobTry++) {
        if ($semobProcess.HasExited) { throw 'Backend não iniciou. Consulte .semob-local\backend-errors.log.' }
        try {
            $semobSchema = Invoke-RestMethod "http://127.0.0.1:$ApiPort/openapi.json" -TimeoutSec 2
            if ($semobSchema.paths.PSObject.Properties.Name -notcontains '/financeiro/overview') {
                throw 'A versão do backend não possui a rota financeira.'
            }
            $semobReady = $true
            break
        } catch { Start-Sleep -Milliseconds 300 }
    }
    if (!$semobReady) { throw 'O backend não respondeu com a rota financeira. Consulte os logs.' }
    Write-Host "Backend desta pasta conectado em http://127.0.0.1:$ApiPort."
    if ($VerificarBackend) {
        $semobFinanceiro = Invoke-RestMethod "http://127.0.0.1:$ApiPort/financeiro/overview?mes=2026-08&periodo=mes" -TimeoutSec 30
        Write-Host "Financeiro respondeu: $($semobFinanceiro.dias) dias disponíveis."
        return
    }
    Push-Location $semobRoot
    try {
        Invoke-SemobFlutter -Arguments @('pub','get')
        if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar dependências Flutter.' }
        Invoke-SemobFlutter -Arguments @('run','-d',$Device,"--web-port=$WebPort","--dart-define=API_URL=http://127.0.0.1:$ApiPort")
        if ($LASTEXITCODE -ne 0) { throw 'O frontend não iniciou corretamente.' }
    } finally { Pop-Location }
} finally {
    if ($semobProcess -and !$semobProcess.HasExited) { Stop-Process -Id $semobProcess.Id }
}

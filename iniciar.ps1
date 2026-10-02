param([switch]$PrepararSomente)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$venvPython = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $venvPython)) {
    $candidates = @("$env:LOCALAPPDATA\Programs\Python\Python313\python.exe", "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe", "$env:LOCALAPPDATA\Programs\Python\Python314\python.exe")
    $systemPython = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $systemPython) {
        $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
        if ($pythonCommand -and $pythonCommand.Source -notlike '*WindowsApps*') { $systemPython = $pythonCommand.Source }
    }
    if (-not $systemPython) { throw 'Instale Python 3.12 ou mais recente em https://www.python.org/downloads/ e execute novamente.' }
    Write-Host 'Preparando o ambiente Python. Isso só é necessário na primeira execução.'
    & $systemPython -m venv (Join-Path $PSScriptRoot '.venv')
    if ($LASTEXITCODE -ne 0) { throw 'Não foi possível criar o ambiente Python.' }
}
$marker = Join-Path $PSScriptRoot '.venv\semob-ready'
if (-not (Test-Path -LiteralPath $marker)) {
    & $venvPython -m pip install -r (Join-Path $PSScriptRoot 'backend\requirements.txt')
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao instalar dependências. Verifique a internet e tente novamente.' }
    Set-Content -LiteralPath $marker -Value 'ready'
}
if ($PrepararSomente) { Write-Host 'Ambiente preparado.'; exit 0 }
& $venvPython (Join-Path $PSScriptRoot 'iniciar.py')
if ($LASTEXITCODE -ne 0) { throw 'O sistema encontrou um problema. Consulte a mensagem acima.' }

"""Serve the included web build and API on loopback; Ctrl+C stops owned processes."""
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import subprocess
import sys
import threading
import time
import urllib.request
import webbrowser
import socket

ROOT=Path(__file__).resolve().parent

def free(port):
    with socket.socket() as s:
        try:
            s.bind(('127.0.0.1',port))
        except OSError:
            return False
    return True


def main():
    if not free(8001) or not free(8081):
        print('As portas 8001/8081 estão ocupadas. Feche a execução anterior antes de iniciar outra.')
        print('Se o SEMOB já está aberto, acesse http://127.0.0.1:8081')
        return 1
    if not (ROOT/'web-dist/index.html').exists():
        print('A interface compilada não foi encontrada. Consulte o README.')
        return 1
    handler=lambda *a,**kw: SimpleHTTPRequestHandler(*a,directory=str(ROOT/'web-dist'),**kw)
    httpd=ThreadingHTTPServer(('127.0.0.1',8081),handler)
    process=subprocess.Popen([sys.executable,'-m','uvicorn','app.main:app','--host','127.0.0.1','--port','8001'],cwd=ROOT/'backend')
    serving=False
    try:
        for _ in range(60):
            if process.poll() is not None:
                raise RuntimeError('O backend encerrou. Consulte o erro acima.')
            try:
                with urllib.request.urlopen('http://127.0.0.1:8001/health',timeout=1) as r:
                    if r.status==200:
                        break
            except Exception:
                time.sleep(.5)
        else:
            raise RuntimeError('A API não respondeu. Verifique a configuração do banco.')
        threading.Thread(target=httpd.serve_forever,daemon=True).start()
        serving=True
        print('\nSEMOB em execução: http://127.0.0.1:8081')
        print('Deixe esta janela aberta. Pressione Ctrl+C para encerrar.\n')
        webbrowser.open('http://127.0.0.1:8081')
        while process.poll() is None:
            time.sleep(1)
    except KeyboardInterrupt:
        print('\nEncerrando SEMOB...')
    finally:
        if serving:
            httpd.shutdown()
        httpd.server_close()
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
    return 0

if __name__=='__main__':
    try:
        sys.exit(main())
    except Exception as error:
        print(f'Falha ao iniciar: {error}')
        sys.exit(1)


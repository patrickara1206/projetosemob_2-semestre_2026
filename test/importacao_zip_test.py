import os
import sys
import unittest
from contextlib import ExitStack
from io import BytesIO
from pathlib import Path
from unittest.mock import AsyncMock, Mock, patch
from zipfile import BadZipFile, ZipFile

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "backend"))

# Importa os módulos reais sem ler credenciais ou conectar a um banco externo.
with (
    patch.dict(os.environ, {"SUPABASE_URL": "https://example.invalid", "SUPABASE_KEY": "test"}),
    patch("dotenv.load_dotenv"),
    patch("supabase.create_client", return_value=Mock()),
):
    from app.services import importacao_service as service
    from app.repositories import importacao_repository as repository


def relatorio(tipo="operacao", mes="2026-08", periodo="mensal", titulo=None):
    data = f"01/{mes[5:]}/{mes[:4]}"
    if tipo == "passageiros":
        df = pd.DataFrame([[mes, "01", 10, 5, 2, 17]], columns=[
            "Mês", "Dia", "Catraca", "Antecipados", "Não Pagantes", "Total Passageiros",
        ])
    elif tipo == "financeiro":
        df = pd.DataFrame([[mes, "01", 100, 40, 60]], columns=[
            "Mês", "Dia", "Total Vendas", "Total Utilização", "Crédito Circulante",
        ])
    else:
        tamanhos = {
            "operacao": 10, "fcv": 9, "linhas": 4, "resumo_faixa_horaria": 4,
            "faixa_horaria": 6, "viagens": 11, "viagens_nao_iniciadas": 15,
            "viagens_nao_realizadas": 15, "viagens_nao_terminadas": 15,
        }
        valores = [data, *([1] * (tamanhos[tipo] - 1))]
        if tipo == "resumo_faixa_horaria":
            valores[1] = "4hs"
        if tipo == "faixa_horaria":
            valores[2] = "4hs"
        if tipo == "viagens":
            valores[6:8] = ["2026-08-01 08:00", "2026-08-01 09:00"]
        if tipo.startswith("viagens_nao_"):
            valores[10:14] = ["2026-08-01 08:00"] * 4
        df = pd.DataFrame([valores])
    titulo = titulo or f"{periodo} - {tipo.replace('_', ' ')}"
    cabecalho = pd.DataFrame({"Geração": ["04/10/2026"]}).to_html(index=False)
    tabelas = cabecalho * (2 if tipo == "financeiro" else 1) + df.to_html(index=False)
    return f"<html><head><meta charset='utf-8'><title>{titulo}</title></head><body>{tabelas}</body></html>".encode("utf-8")


def arquivo_zip(arquivos):
    buffer = BytesIO()
    with ZipFile(buffer, "w") as arquivo:
        for nome, conteudo in arquivos:
            arquivo.writestr(nome, conteudo)
    return buffer.getvalue()


class ImportacaoZipTests(unittest.TestCase):
    def setUp(self):
        self.stack = ExitStack()
        self.addCleanup(self.stack.close)
        self.hash = self.stack.enter_context(patch.object(service, "buscar_importacao_por_hash", return_value=[]))
        self.criar = self.stack.enter_context(patch.object(service, "criar_importacao", side_effect=[{"id": i} for i in range(1, 101)]))
        self.atualizar = self.stack.enter_context(patch.object(service, "atualizar_importacao"))
        self.limpar = self.stack.enter_context(patch.object(service, "limpar_dados_importacao_com_erro"))
        self.stack.enter_context(patch.object(service, "limpar_cache_disponibilidade"))
        self.insercoes = []
        configs = {}
        for tipo, config in service.CONFIG_IMPORTACAO.items():
            configs[tipo] = {**config, "inserir": self._inserir(tipo)}
        self.stack.enter_context(patch.dict(service.CONFIG_IMPORTACAO, configs))

    def _inserir(self, tipo):
        def inserir(df):
            self.insercoes.append((tipo, df.copy()))
        return inserir

    def importar(self, arquivos, **kwargs):
        return service.importar_zip(arquivo_zip(arquivos), "relatorios.zip", "2026-08", **kwargs)

    def test_subpastas_com_multiplos_meses_periodos_e_todos_os_tipos(self):
        arquivos = []
        for mes, periodo in [("2026-07", "mensal"), ("2026-08", "mensal"), ("2026-08", "quinzenal"), ("2026-09", "quinzenal")]:
            for tipo in service.CONFIG_IMPORTACAO:
                arquivos.append((f"pasta/{mes}/{periodo}/{tipo}.HTML", relatorio(tipo, mes, periodo)))
        resultado = self.importar(arquivos)
        self.assertEqual(resultado["status"], "sucesso", resultado["resultados"])
        self.assertEqual(resultado["arquivos_encontrados"], 44)
        self.assertEqual(resultado["arquivos_importados"], 44)
        self.assertEqual(resultado["arquivos_com_erro"], 0)
        self.assertEqual(resultado["total_registros"], 44)
        self.assertEqual(len(self.insercoes), 44)
        self.assertEqual(len({r["arquivo"] for r in resultado["resultados"]}), 44)
        for tipo, df in self.insercoes:
            self.assertIn(tipo, service.CONFIG_IMPORTACAO)
            self.assertEqual(len(df), 1)
            self.assertTrue((df["data"].dt.strftime("%Y-%m") == df["mes_referencia"]).all())

    def test_nome_renomeado_e_titulo_com_acento_identificam_ocorrencia(self):
        resultado = self.importar([("Agosto_2026/Mensal/arquivo (1).htm", relatorio(
            "viagens_nao_iniciadas", titulo="Mensal - Viagens não Iniciadas",
        ))])
        self.assertEqual(resultado["arquivos_importados"], 1, resultado)
        self.assertEqual(self.insercoes[0][0], "viagens_nao_iniciadas")
        self.assertEqual(self.insercoes[0][1]["tipo_ocorrencia"].iloc[0], "nao_iniciada")

    def test_estrutura_sem_nome_conhecido_e_tabela_unica(self):
        conteudo = pd.DataFrame([["01/08/2026", *([1] * 9)]]).to_html(index=False).encode()
        resultado = self.importar([("documento.htm", conteudo)])
        self.assertEqual(resultado["arquivos_importados"], 1, resultado)
        self.assertEqual(self.insercoes[0][0], "operacao")

    def test_relatorio_acumulado_respeita_mes_da_pasta_e_informa_linhas_fora(self):
        df = pd.DataFrame([
            ["2026-08", "31", 100, 40, 60], ["2026-09", "01", 10, 4, 6],
        ], columns=["Mês", "Dia", "Total Vendas", "Total Utilização", "Crédito Circulante"])
        conteudo = ("<meta charset='utf-8'><title>Saldos</title>" + df.to_html(index=False)).encode("utf-8")
        resultado = self.importar([("Agosto_2026/Mensal/Saldos.html", conteudo)])
        self.assertEqual(resultado["arquivos_importados"], 1, resultado)
        self.assertEqual(resultado["total_registros"], 1)
        observacao = resultado["resultados"][0]["observacoes"][0]
        self.assertIn("1 linha(s) diária(s) de 2026-09", observacao)
        self.assertEqual(self.insercoes[0][1]["mes_referencia"].iloc[0], "2026-08")
        ambiguo = self.importar([("Saldos.html", conteudo)])
        self.assertEqual(ambiguo["status"], "erro")

    def test_ocorrencia_com_cabecalho_vazio_valido_nao_inventa_registros(self):
        colunas = [
            "Data", "Linha", "Atendimento", "Prefixo", "Atividade", "Motorista",
            "Sentido", "Tabela", "Status Saída", "Status Chegada", "Início Programado",
            "Início Realizado", "Fim Programado", "Fim Realizado", "kmProd",
        ]
        html = (
            '<title>Quinzenal - Viagens não Iniciadas</title>'
            '<table><tr><td>Smart Report</td></tr></table><table class="data">'
            + "".join(f"<th>{coluna}</th>" for coluna in colunas) + "</table>"
        )
        for encoding in ("utf-8", "cp1252"):
            with self.subTest(encoding=encoding):
                resultado = self.importar([("Setembro_2026/Quinzenal/Viag_Ninic.html", html.encode(encoding))])
                self.assertEqual(resultado["status"], "sucesso", resultado)
                self.assertEqual(resultado["arquivos_sem_dados"], 1)
                self.assertEqual(resultado["arquivos_importados"], 0)
                self.assertEqual(resultado["total_registros"], 0)
        self.criar.assert_not_called()

    def test_ocorrencia_com_apenas_titulo_sem_cabecalho_e_erro(self):
        conteudo = b'<title>Viagens nao Iniciadas</title><table><tr><td>incompleto</td></tr></table>'
        resultado = self.importar([("Viag_Ninic.html", conteudo)])
        self.assertEqual(resultado["status"], "erro")
        self.assertEqual(resultado["arquivos_sem_dados"], 0)
        self.criar.assert_not_called()

    def test_referencias_conflitantes_viram_erro_por_arquivo(self):
        resultado = self.importar([
            ("2026-07/operacao.html", relatorio()),
            ("Mensal/operacao.html", relatorio(periodo="quinzenal")),
            ("operacao.html", relatorio("passageiros")),
            ("ok/operacao.html", relatorio()),
        ])
        self.assertEqual(resultado["status"], "parcial")
        self.assertEqual(resultado["arquivos_importados"], 1)
        self.assertEqual(resultado["arquivos_com_erro"], 3)
        self.assertTrue(all("conflitantes" in r["mensagem"] for r in resultado["resultados"][:3]))
        self.assertEqual(self.criar.call_count, 1)

    def test_html_desconhecido_nao_e_silenciosamente_ignorado(self):
        resultado = self.importar([("pasta/desconhecido.html", b"<html>sem tabela</html>")])
        self.assertEqual(resultado["status"], "erro")
        self.assertEqual(resultado["arquivos_com_erro"], 1)
        self.assertEqual(resultado["arquivos_ignorados"], 0)
        self.assertEqual(resultado["resultados"][0]["arquivo"], "pasta/desconhecido.html")
        self.criar.assert_not_called()

    def test_membro_corrompido_nao_interrompe_os_demais(self):
        leitura_real = ZipFile.read
        def ler(arquivo, item, *args, **kwargs):
            if item.filename == "corrompido.html":
                raise BadZipFile("CRC inválido")
            return leitura_real(arquivo, item, *args, **kwargs)
        with patch.object(ZipFile, "read", ler):
            resultado = self.importar([
                ("corrompido.html", b"x"), ("operacao.html", relatorio()),
            ])
        self.assertEqual(resultado["status"], "parcial")
        self.assertEqual(resultado["arquivos_importados"], 1)
        self.assertIn("CRC", resultado["resultados"][0]["mensagem"])

    def test_hash_concluido_e_contabilizado_sem_reinsercao(self):
        self.hash.return_value = [{"id": 55, "status": "concluido"}]
        resultado = self.importar([("operacao.html", relatorio())])
        self.assertEqual(resultado["arquivos_ja_importados"], 1)
        self.assertEqual(resultado["arquivos_importados"], 0)
        self.assertEqual(resultado["resultados"][0]["status"], "ja_importado")
        self.assertEqual(self.insercoes, [])
        self.limpar.assert_not_called()

    def test_hash_em_processamento_nao_e_retomado(self):
        self.hash.return_value = [{"id": 55, "status": "processando"}]
        resultado = self.importar([("operacao.html", relatorio())])
        self.assertEqual(resultado["status"], "erro")
        self.assertIn("andamento", resultado["resultados"][0]["mensagem"])
        self.limpar.assert_not_called()

    def test_hash_existente_com_outra_referencia_nao_omite_dados_do_lote(self):
        for status in ("erro", "concluido"):
            with self.subTest(status=status):
                self.hash.return_value = [{
                    "id": 55, "status": status, "tipo_relatorio": "operacao",
                    "mes_referencia": "2026-08", "tipo_periodo": "quinzenal",
                }]
                resultado = self.importar([("operacao.html", relatorio())])
                self.assertEqual(resultado["status"], "erro")
                self.assertIn("referência original", resultado["resultados"][0]["mensagem"])
                self.limpar.assert_not_called()
                self.atualizar.assert_not_called()

    def test_quinzenal_com_dados_apos_dia_15_nao_grava_dados(self):
        conteudo = relatorio(periodo="quinzenal").replace(b"01/08/2026", b"31/08/2026")
        resultado = self.importar([("Quinzenal_202608.html", conteudo)])
        self.assertEqual(resultado["status"], "erro")
        self.assertIn("posteriores ao dia 15", resultado["resultados"][0]["mensagem"])
        self.criar.assert_not_called()

    def test_falha_anterior_reutiliza_id_limpa_lotes_parciais_e_conclui(self):
        self.hash.return_value = [{"id": 55, "status": "erro"}]
        resultado = self.importar([("viagens.html", relatorio("viagens"))])
        self.assertEqual(resultado["arquivos_importados"], 1, resultado)
        self.criar.assert_not_called()
        self.limpar.assert_called_once_with(55, "viagens")
        self.assertEqual(self.insercoes[0][1]["importacao_id"].iloc[0], 55)
        self.assertEqual(self.atualizar.call_args.args[1]["status"], "concluido")

    def test_falha_na_limpeza_de_retomada_permanece_retentavel(self):
        self.hash.return_value = [{"id": 55, "status": "erro"}]
        self.limpar.side_effect = RuntimeError("Falha ao remover lote incompleto")
        resultado = self.importar([("operacao.html", relatorio())])
        self.assertEqual(resultado["arquivos_com_erro"], 1)
        self.assertEqual(self.atualizar.call_args.args[1]["status"], "erro")
        self.assertEqual(self.insercoes, [])

    def test_limpeza_de_retomada_afeta_apenas_importacao_em_erro(self):
        banco = Mock()
        with patch.object(repository, "supabase", banco):
            repository.limpar_dados_importacao_com_erro(55, "viagens_nao_iniciadas")
        banco.table.assert_called_once_with("viagens_ocorrencias")
        banco.table.return_value.delete.return_value.eq.assert_called_once_with("importacao_id", 55)

    def test_upload_individual_preserva_validacao_mes_e_periodo_selecionados(self):
        with self.assertRaisesRegex(ValueError, "mês selecionado"):
            service.importar_relatorio("operacao", relatorio(), "Mensal_202608.html", "2026-07")
        with self.assertRaisesRegex(ValueError, "período selecionado"):
            service.importar_relatorio("operacao", relatorio(), "Mensal_202608.html", "2026-08", "quinzenal")
        self.criar.assert_not_called()

    def test_zip_invalido_ou_sem_html_rejeitado(self):
        with self.assertRaisesRegex(ValueError, "ZIP válido"):
            service.importar_zip(b"invalido", "x.zip", "2026-08")
        with self.assertRaisesRegex(ValueError, "não contém"):
            self.importar([("leia.txt", b"texto")])

    def test_rota_preserva_status_parcial_e_detalhes_para_interface(self):
        from app.routes import importacao
        parcial = {
            "status": "parcial", "arquivos_importados": 1, "arquivos_com_erro": 1,
            "resultados": [{"arquivo": "pasta/x.html", "status": "erro", "mensagem": "CRC inválido"}],
        }
        with patch.object(importacao, "importar_zip", return_value=parcial):
            corrotina = importacao.importar_pasta_zipada(
                mes="2026-08", arquivo=Mock(filename="dados.zip", read=AsyncMock(return_value=b"zip")),
            )
            # O upload está simulado e seu await conclui imediatamente.
            # Dispensa abrir sockets de um event loop neste teste unitário.
            with self.assertRaises(StopIteration) as fim:
                corrotina.send(None)
        self.assertEqual(fim.exception.value, parcial)

    @unittest.skipUnless(os.getenv("SEMOB_ZIP_VALIDACAO"), "Dataset externo não fornecido")
    def test_dataset_real_com_44_arquivos_sem_gravar_banco(self):
        resultado = service.importar_zip(
            Path(os.environ["SEMOB_ZIP_VALIDACAO"]).read_bytes(), "transport.zip", "2026-08"
        )
        erros = [r for r in resultado["resultados"] if r["status"] not in {"sucesso", "sem_dados"}]
        self.assertEqual(resultado["arquivos_encontrados"], 44)
        self.assertEqual(resultado["arquivos_importados"], 43, erros)
        self.assertEqual(resultado["arquivos_sem_dados"], 1, erros)
        self.assertEqual(resultado["arquivos_com_erro"], 0, erros)
        grupos = {}
        for registro in resultado["resultados"]:
            grupo = (registro["mes_referencia"], registro["tipo_periodo"])
            grupos.setdefault(grupo, set()).add(registro["tipo_relatorio"])
        self.assertEqual(set(grupos), {
            ("2026-07", "mensal"), ("2026-08", "mensal"),
            ("2026-08", "quinzenal"), ("2026-09", "quinzenal"),
        })
        self.assertTrue(all(tipos == set(service.CONFIG_IMPORTACAO) for tipos in grupos.values()))
        self.assertEqual(resultado["total_registros"], sum(len(df) for _, df in self.insercoes))
        print(f"Dataset real: {resultado['arquivos_importados']} arquivos importados; {resultado['arquivos_sem_dados']} vazio; {resultado['total_registros']} registros; grupos={sorted(grupos)}")


if __name__ == "__main__":
    unittest.main()

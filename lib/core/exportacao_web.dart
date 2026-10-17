import 'dart:js_interop';

@JS('semobDownloadCsv')
external JSFunction? get _download;

bool salvarCsv(String nome, String conteudo) {
  final download = _download;
  if (download == null) return false;
  download.callAsFunction(null, nome.toJS, conteudo.toJS);
  return true;
}

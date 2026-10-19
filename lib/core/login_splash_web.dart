import 'dart:js_interop';

@JS('semobLoginReady')
external JSFunction? get _loginReady;

@JS('semobAppReady')
external JSFunction? get _appReady;

void notifyLoginReady(
  double left,
  double top,
  double width,
  double height,
) {
  _loginReady?.callAsFunction(
    null,
    left.toJS,
    top.toJS,
    width.toJS,
    height.toJS,
  );
}

void notifyAppReady() {
  _appReady?.callAsFunction(null);
}
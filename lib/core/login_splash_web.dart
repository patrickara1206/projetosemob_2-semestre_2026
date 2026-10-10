import 'dart:js_interop';

@JS('semobLoginReady')
external JSFunction? get _loginReady;

void notifyLoginReady(double left, double top, double width, double height) {
  _loginReady?.callAsFunction(null, left.toJS, top.toJS, width.toJS, height.toJS);
}

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

Future<void>? _loading;

Future<void> ensureMapsLoaded(String key) => _loading ??= _load(key);

bool get _alreadyLoaded {
  final google = globalContext['google'];
  return google != null && (google as JSObject)['maps'] != null;
}

Future<void> _load(String key) {
  if (_alreadyLoaded) return Future.value();
  if (key.isEmpty) {
    _loading = null;
    return Future.error(StateError('missing-key'));
  }

  final completer = Completer<void>();
  globalContext['__quickcareMapsReady'] = (() {
    if (!completer.isCompleted) completer.complete();
  }).toJS;

  final document = globalContext['document'] as JSObject;
  final script = document.callMethod<JSObject>('createElement'.toJS, 'script'.toJS);
  script['src'] =
      'https://maps.googleapis.com/maps/api/js?key=${Uri.encodeComponent(key)}&callback=__quickcareMapsReady'.toJS;
  script['async'] = true.toJS;
  script['onerror'] = ((JSAny? _) {
    _loading = null;
    if (!completer.isCompleted) completer.completeError(StateError('load-failed'));
  }).toJS;
  (document['head'] as JSObject).callMethod<JSAny?>('appendChild'.toJS, script);
  return completer.future;
}

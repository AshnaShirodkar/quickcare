import 'maps_loader_stub.dart' if (dart.library.js_interop) 'maps_loader_web.dart' as impl;

/// Google Maps key, read from the project-root .env file when the app is run with
/// `--dart-define-from-file=.env`. Only the web build needs it here; iOS and Android
/// read the same .env file through their native build settings.
const mapsApiKey = String.fromEnvironment('MAPS_API_KEY');

/// Makes sure the Google Maps JavaScript API is ready (web only; a no-op elsewhere).
Future<void> ensureMapsLoaded() => impl.ensureMapsLoaded(mapsApiKey);

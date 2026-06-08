import 'external_url_launcher_stub.dart'
    if (dart.library.html) 'external_url_launcher_web.dart'
    if (dart.library.io) 'external_url_launcher_io.dart'
    as launcher;

abstract final class ExternalUrlLauncher {
  static Future<bool> open(String url) => launcher.openExternalUrl(url);
}

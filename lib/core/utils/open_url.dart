import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

void openDeepLink(String url) async {
  try {
    final String encodedUrl = Uri.encodeFull(url);
    final Uri uri = Uri.parse(encodedUrl);
    log('Opening $uri');
    await launchUrl(uri);
  } catch (e) {
    log('Error launching $url: $e');
  }
}

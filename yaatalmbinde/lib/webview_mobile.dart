import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview_interface.dart';

class MobileWebView implements WebViewInterface {
  @override
  Widget buildWebView(String url) {
    return WebViewWidget(
      controller: WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            onHttpError: (HttpResponseError error) {},
            onWebResourceError: (WebResourceError error) {},
          ),
        )
        ..loadRequest(Uri.parse(url)),
    );
  }
}
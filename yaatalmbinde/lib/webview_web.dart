import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'webview_interface.dart';

class WebWebView implements WebViewInterface {
  @override
  Widget buildWebView(String url) {
    // Créer un ID unique pour l'iframe
    final String viewId = 'webview_${DateTime.now().millisecondsSinceEpoch}';
    
    // Enregistrer l'iframe comme plateforme view
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%',
    );

    return HtmlElementView(viewType: viewId);
  }
}
import 'webview_interface.dart';
import 'webview_factory_mobile.dart' if (dart.library.html) 'webview_factory_web.dart' as webview_factory;

WebViewInterface createWebView() {
  return webview_factory.createWebView();
}
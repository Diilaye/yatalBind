import 'package:flutter/material.dart';
import 'webview_factory.dart';
import 'webview_interface.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewInterface webViewInterface;
  
  @override
  void initState() {
    super.initState();
    webViewInterface = createWebView();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: webViewInterface.buildWebView('https://yaatalmbinde.sn/'),
      ),
    );
  }
}

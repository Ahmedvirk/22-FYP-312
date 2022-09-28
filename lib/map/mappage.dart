import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapPage extends StatefulWidget {
  final String url;
  const MapPage(this.url, {Key? key}) : super(key: key);
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  int loading = 0;
  showLoader(l) {
    loading = l;
    if (kDebugMode) {
      print(loading);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Visibility(
        visible: true,
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          onProgress: showLoader,
          initialUrl: widget.url,
        ),
      ),
    );
  }
}

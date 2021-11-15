import 'package:flutter/material.dart';

import 'Webview.dart';

void main() {
  runApp(const KigoApp());
}

class KigoApp extends StatelessWidget {
  const KigoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KigoWebview',
      home: Webview(),
    );
  }
}

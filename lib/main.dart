import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Webview.dart';

Future<void> main() async {
  bool data = await fetchData();

  runApp(const KigoApp());
}

class KigoApp extends StatelessWidget {
  const KigoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KigoWebview',
      debugShowCheckedModeBanner: false,
      home: Screen(),
    );
  }
}

Future<bool> fetchData() async {
  bool data = false;

  await Future.delayed(Duration(seconds: 3), () {
    data = true;
  });

  return data;
}

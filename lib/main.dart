import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'Webview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const KigoApp());
}

class KigoApp extends StatelessWidget {
  const KigoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // _addFirebaseMessageListener();
    //세로 고정
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return GetMaterialApp(
      title: 'Kigo',
      debugShowCheckedModeBanner: false,
      home: Screen(),
    );
  }
}

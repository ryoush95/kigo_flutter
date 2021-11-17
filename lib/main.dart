import 'package:flutter/material.dart';

import 'Webview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(const KigoApp());
}

class KigoApp extends StatelessWidget {
  const KigoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KigoWebview',
      home: MyWebview(),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kigo_flutter/page_event_connector.dart';
import 'Webview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: false,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false, // Required to display a heads up notification
    badge: true,
    sound: false,
  );

  runApp(const KigoApp());
}

Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class KigoApp extends StatelessWidget {
  const KigoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _addFirebaseMessageListener();

    return GetMaterialApp(
      title: 'Kigo',
      debugShowCheckedModeBanner: false,
      home: Screen(),
    );
  }

  void _addFirebaseMessageListener() async {
    RemoteMessage? message =
    await FirebaseMessaging.instance.getInitialMessage();

    // 종료, 비활성 상태일 때 푸시가 "도착"하면 실행됨.
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

    // 활성 상태일 때 푸시가 "도착"하면 실행됨.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification!;
      print(message.data);
      PageEventConnector().onForegroundFirebaseMessage(
          message.notification?.title,
          message.notification?.body,
          message.data['url']);
    });
  }
}

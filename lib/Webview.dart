import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:kigo_flutter/bokkey.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Screen extends StatefulWidget {
  const Screen({Key? key}) : super(key: key);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  InAppWebViewController? _controller;
  bool onLoad = false;
  final awsurl = key.url;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Permission.camera.status.isGranted == false ||
        Permission.storage.status.isGranted == false) {
      requestCameraPermission(context);
    }

    getForeground();
  }

  void getForeground() async {
    String? t = await messaging.getToken();
    print(t);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: false, // Required to display a heads up notification
        badge: true,
        sound: false,
      );
    }

    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      'high_importance_channel', // 임의의 id
      'High Importance Notifications', // 설정에 보일 채널명
      description:
          'This channel is used for important notifications.', // 설정에 보일 채널 설명
      importance: Importance.max,
    );

    // Notification Channel을 디바이스에 생성
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(message.notification?.title);
      Get.dialog(AlertDialog(
        title: Text(message.notification!.title!),
        content: Text(message.notification!.body!),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('ok'))
        ],
      ));
    });
  }

  Future<bool> requestCameraPermission(BuildContext context) async {
    // PermissionStatus status = await Permission.storage.request();
    Map<Permission, PermissionStatus> statuses =
        await [Permission.camera, Permission.storage].request();
    // var status = await requestCameraPermission(context);

    if (statuses[Permission.camera]!.isGranted == false ||
        statuses[Permission.storage]!.isGranted == false) {
      // 허용이 안된 경우
      Fluttertoast.showToast(
          msg: '허용되지않은 권한이 있습니다.\n 설정에서 확인해주세요.',
          toastLength: Toast.LENGTH_LONG);
      if (Platform.isAndroid) {
        openAppSettings();
      }
      print("permission denied by user");
      return false;
    }
    print("permission ok");

    return true;
  }

  Future<bool> onWillPop() async {
    print(_controller!.canGoBack);
    if (await _controller!.canGoBack()) {
      _controller!.goBack();
      print("else");
      return false;
    } else {
      bool exit = false;
      await Get.dialog(
        AlertDialog(
          content: Text('앱 종료?'),
          actions: [
            TextButton(
              onPressed: () {
                exit = true;
                SystemNavigator.pop();
              },
              child: Text('네'),
            ),
            TextButton(
              onPressed: () {
                exit = false;
                Get.back();
              },
              child: Text('아니오'),
            ),
          ],
        ),
      );
      return exit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: onWillPop,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                      child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: Uri.parse(awsurl),
                    ),
                    onWebViewCreated: (controller) {
                      _controller ??= controller;
                      controller.addJavaScriptHandler(
                        handlerName: 'JavaScriptHandler',
                        callback: (args) async {
                          print(args);
                          // return
                        },
                      );
                    },
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                        clearCache: false,
                        mediaPlaybackRequiresUserGesture: false,
                        useShouldOverrideUrlLoading: true,
                        useOnDownloadStart: true,
                      ),
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                      ),
                      ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: true,
                      ),
                    ),
                    onLoadStart: (con, url) async {
                      setState(() {
                        onLoad = true;
                      });
                    },
                    onLoadStop: (con, url) async {
                      setState(() {
                        onLoad = false;
                      });
                    },
                  )),
                  // bottom(),
                ],
              ),
              Visibility(
                visible: onLoad,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}

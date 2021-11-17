import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'Setting.dart';

class MyWebview extends StatefulWidget {
  const MyWebview({Key? key}) : super(key: key);

  @override
  _MyWebviewState createState() => _MyWebviewState();
}

class _MyWebviewState extends State<MyWebview> {
  late WebViewController _controller;
  late FirebaseMessaging _fcm;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    _fcm = FirebaseMessaging.instance;
    _fcm.getToken().then((value) =>print('token: ' + value!));
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.title);
      print(event.notification!.body);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(event.notification!.title!),
              content: Text(event.notification!.body!),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

    @override
    Widget build(BuildContext context) {
      return WillPopScope(
        onWillPop: () {
          Future future = _controller.canGoBack();
          future.then((canGoBack) {
            if (canGoBack) {
              _controller.goBack();
            } else {
              showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(
                      title: Text("앱을 종료하시겠습니까?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => SystemNavigator.pop(),
                          child: Text("네"),
                        ),
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("아니요"))
                      ],
                    ),
              );
            }
          });
          return Future.value(false);
        },
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Setting()),
              );
            },
            child: Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
          // appBar: AppBar(
          //   backgroundColor: Colors.white,
          //   elevation: 0.0,
          //   leading: IconButton(
          //     onPressed: () {
          //       Future future = _controller.canGoBack();
          //       future.then((canGoBack) {
          //         if (canGoBack) {
          //           _controller.goBack();
          //         } else {
          //           print('fail');
          //         }
          //       });
          //     },
          //     icon: Icon(Icons.arrow_back),
          //     color: Colors.black,
          //   ),
          //   actions: [
          //     IconButton(
          //       onPressed: () {
          //         print('2222');
          //       },
          //       icon: Icon(Icons.settings),
          //       color: Colors.black,
          //     ),
          //   ],
          // ),
          body: SafeArea(
            child: WebView(
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
              },
              initialUrl:
              'http://ec2-15-164-219-91.ap-northeast-2.compute.amazonaws.com:3000/',
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
        ),
      );
    }
  }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Screen extends StatefulWidget {
  const Screen({Key? key}) : super(key: key);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  InAppWebViewController? _controller;
  bool onload = false;
  DateTime backbuttonpressedTime = DateTime.now();

  // final flutterPlugin = FlutterWebviewPlugin();
  final awsurl =
      'http://ec2-15-164-169-144.ap-northeast-2.compute.amazonaws.com:3000/';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Permission.camera.status.isGranted == false ||
        Permission.storage.status.isGranted == false) {
      requestCameraPermission(context);
    }
  }

  Future<bool> onWillPop() async {
    // DateTime currentTime = DateTime.now();

    //Statement 1 Or statement2
    // bool backButton =
    //     currentTime.difference(backbuttonpressedTime) > Duration(seconds: 3);

    print(_controller!.canGoBack);
    if (await _controller!.canGoBack()) {
      _controller!.goBack();
      print("else");
      return false;
    } else {
      //   if (backButton) {
      //     backbuttonpressedTime = currentTime;
      //     Fluttertoast.showToast(
      //         msg: "한번 더 누르시면 종료 됩니다",
      //         backgroundColor: Colors.black,
      //         textColor: Colors.white);
      //     return false;
      //   } else {
      //     SystemNavigator.pop();
      //     return true;
      //   }
      // }
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
              child: Text('cancel'),
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
                        onload = true;
                      });
                    },
                    onLoadStop: (con, url) async {
                      setState(() {
                        onload = false;
                      });
                    },
                  )),

                  // bottom(),
                ],
              ),
              Visibility(
                visible: onload,
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

  SizedBox bottom() {
    if (Platform.isIOS) {
      return SizedBox(
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                onWillPop();
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.arrow_forward),
            //   onPressed: () {
            //     controller.goForward();
            //   },
            // ),
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }

  void showToast(String msg) {
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
  }
}

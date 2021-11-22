import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class Webview extends StatefulWidget {
  const Webview({Key? key}) : super(key: key);

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  late WebViewController _controller;
  var permissionState = false;

  Future<bool> requestCameraPermission(BuildContext context) async {
    // PermissionStatus status = await Permission.storage.request();
    Map<Permission, PermissionStatus> statuses =
    await [Permission.camera, Permission.storage].request();
    // var status = await requestCameraPermission(context);

    if (statuses[Permission.camera]!.isGranted == false ||
    statuses[Permission.storage]!.isGranted == false) {
      // 허용이 안된 경우
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("권한 설정을 확인해주세요."),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      openAppSettings(); // 앱 설정으로 이동
                    },
                    child: Text('설정하기')),
              ],
            );
          });
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

    requestCameraPermission(context);
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
              builder: (context) => AlertDialog(
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
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => Setting()),
        //     );
        //   },
        //   child: Icon(
        //     Icons.settings,
        //     color: Colors.white,
        //   ),
        // ),
        body: SafeArea(
          child: WebviewScaffold(
            url: 'http://ec2-15-164-219-91.ap-northeast-2.compute.amazonaws.com:3000/',
            withJavascript: true,
            withLocalStorage: true,


          ),
        ),
      ),
    );
  }
}

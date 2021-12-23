import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Webview extends StatefulWidget {
  const Webview({Key? key}) : super(key: key);

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  final _controller = FlutterWebviewPlugin();
  var permissionState = false;
  DateTime backbuttonpressedTime = DateTime.now();

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

  Future<bool> onWillPop() async {
    DateTime currentTime = DateTime.now();

    //Statement 1 Or statement2
    bool backButton = currentTime.difference(backbuttonpressedTime) > Duration(seconds: 3);

    if (_controller.canGoBack == true) {
      _controller.goBack();
      print("else");
      return false;
    } else {
      if (backButton) {
        backbuttonpressedTime = currentTime;
        Fluttertoast.showToast(
            msg: "한번 더 누르시면 종료 됩니다",
            backgroundColor: Colors.black,
            textColor: Colors.white);
        return false;
      } else{
        SystemNavigator.pop();
        return true;
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // onWillPop: () {
      //   Future future = _controller.canGoBack();
      //   future.then((canGoBack) {
      //     if (canGoBack) {
      //       _controller.goBack();
      //     } else {
      //       showToast('한번 더 뒤로가기 클릭시 종료됩니다');
      //     }
      //   });
      //   return Future.value(false);
      // },
      onWillPop: onWillPop,
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
          child: Container(
            child: WebviewScaffold(
              url:'http://ec2-15-164-219-91.ap-northeast-2.compute.amazonaws.com:3000/',
              withJavascript: true,
              withLocalStorage: true,
            ),
          ),
        ),
      ),
    );
  }

  void showToast(String msg){
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
  }
}

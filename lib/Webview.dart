import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Webview extends StatefulWidget {
  const Webview({Key? key}) : super(key: key);

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  late WebViewController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        var future = _controller.canGoBack();
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
                    ));
          }
        });
        return Future.value(false);
      },
      child: Scaffold(
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

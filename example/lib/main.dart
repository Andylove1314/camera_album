import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:camera_album/camera_album.dart';

import 'newpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await CameraAlbum.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Center(
      child: Stack(children: <Widget>[

        ///原生view
        getPlatformTextView(),

        IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              String res =
              await CameraAlbum.openAlbum(null, callback: (path) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return NewPage(
                        path,
                      );
                    }));
              });
              print(res);
            })
      ],),
    ),);
  }

  Widget getPlatformTextView() {
    if (Platform.isAndroid) {
      return Container(child: AndroidView(
          viewType: "platform_text_view",
          creationParams: <String, dynamic>{"text": "Android Text View"},
          creationParamsCodec: const StandardMessageCodec()),color: Colors.green,);
    } else if (Platform.isIOS) {
      return UiKitView(
          viewType: "platform_text_view",
          creationParams: <String, dynamic>{"text": "iOS Label"},
          creationParamsCodec: const StandardMessageCodec());
    } else {
      return Text("Not supported");
    }
  }
}


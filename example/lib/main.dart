import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:camera_album/camera_album.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  Uint8List _image;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    var channel = MethodChannel('flutter/camera_album');
    channel.setMethodCallHandler((call) {
      setState(() {
        print(call.arguments);
        _platformVersion = "${call.arguments["file"]}";
        _image = call.arguments["image"];
      });
      return;
    });
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

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(_platformVersion),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    child: LayoutBuilder(
                      builder: (c, cc) {
                        return UiKitView(
                          viewType: "platform_gallery_view",
                          creationParams: <String, dynamic>{
                            "text": "iOS Label 选照片",
                            "y": 0,
                            "height": cc.maxHeight - kToolbarHeight,
                          },
                          creationParamsCodec: const StandardMessageCodec(),
                        );
                      },
                    ),
                  ),
                  Container(
                      color: Colors.red,
                      width: 200,
                      height: 200,
                      child: _image == null
                          ? Container()
                          : Image.memory(
                              _image,
                            )),
                ],
              ),
            ),
            FlatButton(
              child: Text("拍照"),
              onPressed: () {

              },
            ),
          ],
        ),
      ),
    );
  }
}

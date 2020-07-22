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
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ///原生view
        getPlatformTextView(),

        IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              CameraAlbum.openAlbum({
                'title': 'Paint video',
                'input': 'image',
                'firstCamera': false,
                'showBottomCamera': true,
                'showAlbum':true,
                'isMulti': true,
                'multiCount': 5,
                'guides': [
                  'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/VHByy0e26624d87a5a1156eea6711d5125858.jpg',
                  'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/Vt8Rtc3d879d7ce5278fb0655ab0d90503d86.jpg',
                  'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/djwxl6cc4e8157b1bc1d90dd1a34268572d1a.jpg'
                ]
              }, callback: (backs) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return NewPage(
                    backs['paths'],
                  );
                }));
              });
            })
      ],
    );
  }

  Widget getPlatformTextView() {
    if (Platform.isAndroid) {
      return Container(
        child: AndroidView(
            viewType: "platform_text_view",
            creationParams: <String, dynamic>{"text": "Android Text View"},
            creationParamsCodec: const StandardMessageCodec()),
        color: Colors.green,
      );
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

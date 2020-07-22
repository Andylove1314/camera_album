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
    return Stack(alignment: Alignment.center,children: <Widget>[

      ///原生view
      getPlatformTextView(),

      IconButton(
          icon: Icon(Icons.add),
          onPressed: () async {
            CameraAlbum.openAlbum({'title':'Paint video','input':'image','isMulti':false,'guides':['http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-06/30/JZ2JU3e1501ea2a2673101b2bd8ef6b6fbb96.png','http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-06/30/JZ2JU3e1501ea2a2673101b2bd8ef6b6fbb96.png','http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-06/30/JZ2JU3e1501ea2a2673101b2bd8ef6b6fbb96.png']}, callback: (backs) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return NewPage(
                      backs['paths'][0],
                    );
                  }));
            });
          })
    ],);
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


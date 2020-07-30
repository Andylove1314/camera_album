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
    return Column(
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.photo),
            onPressed: () async {
              CameraAlbum.openAlbum(
                  config: CameraAlbumConfig(
                      actionId: 'ssshshhshsh',
                      title: 'Native Gallery',
                      inType: 'image',
                      firstCamera: false,
                      showBottomCamera: true,
                      showGridCamera: true,
                      showAlbum: true,
                      isMulti: false,
                      multiCount: 1,
                      guides: [
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/VHByy0e26624d87a5a1156eea6711d5125858.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/VHByy0e26624d87a5a1156eea6711d5125858.jpg'
                        ],
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/Vt8Rtc3d879d7ce5278fb0655ab0d90503d86.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/Vt8Rtc3d879d7ce5278fb0655ab0d90503d86.jpg'
                        ],
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/djwxl6cc4e8157b1bc1d90dd1a34268572d1a.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/djwxl6cc4e8157b1bc1d90dd1a34268572d1a.jpg'
                        ]
                      ]),
                  context: context,
                  callback: (backs) {
                    print('callback2： -> $backs');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return NewPage(
                        MediaType.image,
                        backs.paths,
                      );
                    }));
                  },
                  androidView: false,
                  callCamera: () {
                    print('open custom camera');
                  });
            }),
        IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: () async {
              CameraAlbum.openAlbum(
                  config: CameraAlbumConfig(
                      actionId: 'ssshshhshsh',
                      title: 'Native Gallery',
                      inType: 'image',
                      firstCamera: false,
                      showBottomCamera: true,
                      showGridCamera: true,
                      showAlbum: true,
                      isMulti: true,
                      multiCount: 5,
                      guides: [
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/VHByy0e26624d87a5a1156eea6711d5125858.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/VHByy0e26624d87a5a1156eea6711d5125858.jpg'
                        ],
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/Vt8Rtc3d879d7ce5278fb0655ab0d90503d86.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/Vt8Rtc3d879d7ce5278fb0655ab0d90503d86.jpg'
                        ],
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/djwxl6cc4e8157b1bc1d90dd1a34268572d1a.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/djwxl6cc4e8157b1bc1d90dd1a34268572d1a.jpg'
                        ]
                      ]),
                  context: context,
                  callback: (backs) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return NewPage(
                        MediaType.image,
                        backs.paths,
                      );
                    }));
                  },
                  onLimitCallback: () {
                    print("超出限制");
                    showDialog(
                        context: context,
                        builder: (c) {
                          return AlertDialog(
                            title: Text('超出限制'),
                            actions: <Widget>[
                              RaisedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('ok')),
                            ],
                          );
                        });
                  });
            }),
        IconButton(
            icon: Icon(Icons.video_label),
            onPressed: () async {
              CameraAlbum.openAlbum(
                  config: CameraAlbumConfig(
                      title: 'Paint video',
                      inType: 'video',
                      firstCamera: false,
                      showBottomCamera: true,
                      showGridCamera: true,
                      showAlbum: true,
                      isMulti: true,
                      multiCount: 1,
                      guides: [
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/VHByy0e26624d87a5a1156eea6711d5125858.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/VHByy0e26624d87a5a1156eea6711d5125858.jpg'
                        ],
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/Vt8Rtc3d879d7ce5278fb0655ab0d90503d86.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/Vt8Rtc3d879d7ce5278fb0655ab0d90503d86.jpg'
                        ],
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/djwxl6cc4e8157b1bc1d90dd1a34268572d1a.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/djwxl6cc4e8157b1bc1d90dd1a34268572d1a.jpg'
                        ]
                      ]),
                  context: context,
                  callback: (backs) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return NewPage(
                        MediaType.video,
                        backs.paths,
                      );
                    }));
                  });
            }),
        IconButton(
            icon: Icon(Icons.video_library),
            onPressed: () async {
              CameraAlbum.openAlbum(
                  config: CameraAlbumConfig(
                      actionId: '你好',
                      title: 'Paint video',
                      inType: 'video',
                      firstCamera: false,
                      showBottomCamera: true,
                      showGridCamera: true,
                      showAlbum: true,
                      isMulti: true,
                      multiCount: 5,
                      guides: [
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/VHByy0e26624d87a5a1156eea6711d5125858.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/VHByy0e26624d87a5a1156eea6711d5125858.jpg'
                        ],
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/Vt8Rtc3d879d7ce5278fb0655ab0d90503d86.jpg',
                          'https://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/remini/s/2020/1595847490451_439384610.mp4'
                        ],
                        [
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/djwxl6cc4e8157b1bc1d90dd1a34268572d1a.jpg',
                          'http://nwdn-hd2.oss-cn-shanghai.aliyuncs.com/back/2020-03/20/djwxl6cc4e8157b1bc1d90dd1a34268572d1a.jpg'
                        ]
                      ]),
                  context: context,
                  callback: (backs) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return NewPage(
                        MediaType.video,
                        backs.paths,
                      );
                    }));
                  });
            }),
        IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Scaffold(
                    appBar: AppBar(
                      title: Text("Camera"),
                    ),
                    body: Column(
                      children: <Widget>[
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              UIKitCamera(),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  margin:
                                      EdgeInsets.only(bottom: 50, right: 40),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.group_work,
                                      size: 80,
                                    ),
                                    onPressed: () {
                                      CameraAlbum.takePhoto((path) async {
                                        debugPrint(path);

                                        await Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return NewPage(
                                              MediaType.image, [path]);
                                        }));
                                        CameraAlbum.startCamera();
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.switch_camera),
                          onPressed: () {
                            CameraAlbum.switchCamera();
                          },
                        ),
                      ],
                    ));
              }));
            }),
      ],
    );
  }
}

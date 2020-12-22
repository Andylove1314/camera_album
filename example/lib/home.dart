
import 'package:camera_album/camera_album.dart';
import 'package:camera_album_example/app_photo_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'android_camera_widget.dart';
import 'newpage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CupertinoButton(
            child: Row(
              children: [
                Icon(Icons.add_photo_alternate),
                Text('Thrio single picture'),
              ],
            ),
            onPressed: () async {
              AppPhotoLibrary.showPhotoLibrary(
                  taskTitle: "照片单选",
                  takeTitle: "Take a picture",
                  );
            },
          ),
          CupertinoButton(
            child: Row(
              children: [
                Icon(Icons.add_photo_alternate),
                Text('Thrio multiple picture'),
              ],
            ),
            onPressed: () async {
              AppPhotoLibrary.showPhotoLibrary(
                maxSelectCount: 9,
                  taskTitle: "照片多选",
                  takeTitle: "pictures",
                  );
            },
          ),
          CupertinoButton(
            child: Row(
              children: [
                Icon(Icons.wb_sunny),
                Text('Thrio single video'),
              ],
            ),
            onPressed: () async {
              AppPhotoLibrary.showPhotoLibrary(
                mediaType: MediaType.video,
                taskTitle: "视频单选",
                takeTitle: "Take a video",
              );
            },
          ),
          CupertinoButton(
            child: Row(
              children: [
                Icon(Icons.add_photo_alternate),
                Text('Remini single picture'),
              ],
            ),
            onPressed: () async {
              CameraAlbum.showPhotoLibrary(
                  taskTitle: "照片单选",
                  takeTitle: "Take a picture",
                  onSelected: (List<CameraAlbumModel> list) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return NewPage(
                            MediaType.image,
                            list.map((e) => e.originPath).toList(),
                            previewPaths: list.map((e) => e.previewPath).toList(),
                          );
                        }));
                  },
                  openCamera: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return CameraDemo(
                            isRecordVideo: false,
                          );
                        }));
                  });
            },
          ),
          CupertinoButton(
            child: Row(
              children: [
                Icon(Icons.add_photo_alternate),
                Text('Remini single video'),
              ],
            ),
            onPressed: () async {
              CameraAlbum.showPhotoLibrary(
                  mediaType: MediaType.video,
                  taskTitle: "视频单选",
                  takeTitle: "Take a video",
                  onSelected: (List<CameraAlbumModel> list) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return NewPage(
                            MediaType.video,
                            list.map((e) => e.originPath).toList(),
                            durs: list.map((e) => e.duration).toList(),
                            previewPaths: list.map((e) => e.previewPath).toList(),
                          );
                        }));
                  },
                  openCamera: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return CameraDemo(
                            isRecordVideo: true,
                          );
                        }));
                  });
            },
          ),
          CupertinoButton(
            child: Row(
              children: [
                Icon(Icons.add_photo_alternate),
                Text('Remini multiple picture'),
              ],
            ),
            onPressed: () async {
              CameraAlbum.showPhotoLibrary(
                  maxSelectCount: 9,
                  onSelected: (List<CameraAlbumModel> list) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return NewPage(
                            MediaType.image,
                            list.map((e) => e.originPath).toList(),
                            previewPaths: list.map((e) => e.previewPath).toList(),
                          );
                        }));
                  });
            },
          ),
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
                        isMulti: true,
                        multiCount: 5,
                        cute: false,
                        customCamera: true,
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
                    androidView: true,
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
                    callCamera: () {
                      print('open custom camera');
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
              icon: Icon(Icons.photo_library),
              onPressed: () async {
                CameraAlbum.openAlbum(
                    config: CameraAlbumConfig(
                        actionId: 'ssshshhshsh',
                        autoShowGuide: false,
                        title: 'Native Gallery',
                        inType: 'image',
                        firstCamera: false,
                        showBottomCamera: true,
                        showGridCamera: true,
                        customCamera: true,
                        showAlbum: true,
                        isMulti: true,
                        multiCount: 5,
                        bottomActionTitle: 'fuck camera',
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
                  return CameraDemo(
                    isRecordVideo: false,
                  );
                }));
              }),
          IconButton(
              icon: Icon(Icons.video_call),
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CameraDemo(
                    isRecordVideo: true,
                  );
                }));
              }),
          GestureDetector(
            child: Row(
              children: <Widget>[
                Icon(Icons.camera),
                Text('android camera view')
              ],
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AndroidCameraPage();
              }));
            },
          ),
          IconButton(
              icon: Icon(Icons.image),
              onPressed: () async {
                CameraAlbum.requestLastImage('image').then((imge) {
                  print('last img:$imge');
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return NewPage(
                      MediaType.image,
                      ['$imge'],
                    );
                  }));
                });
              }),
        ],
      ),
    );
  }
}

class CameraDemo extends StatefulWidget {
  final bool isRecordVideo;

  const CameraDemo({Key key, @required this.isRecordVideo}) : super(key: key);

  @override
  _CameraDemoState createState() => _CameraDemoState();
}

class _CameraDemoState extends State<CameraDemo> {
  /// 是否可以点击拍照
  bool enableTakePhoto = true;

  /*
  off = 0
  on = 1
  auto = 2
   */
  CaptureDeviceFlashMode flashMode = CaptureDeviceFlashMode.off;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isRecordVideo ? "Record" : "Camera",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: Color(0xFF333333),
            ),
          ),
          actions: <Widget>[
            CupertinoButton(
                child: Text(
                  flashMode.index == 0
                      ? "OFF"
                      : flashMode.index == 1
                      ? "ON"
                      : "AUTO",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF333333),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    int index = 0;
                    index = flashMode.index < (widget.isRecordVideo ? 1 : 2)
                        ? flashMode.index + 1
                        : 0;
                    flashMode = CaptureDeviceFlashMode.values[index];
                    CameraAlbum.setFlashMode(flashMode);
                  });
                })
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  UIKitCamera(
                    isRecordVideo: widget.isRecordVideo,
                  ),
                  Center(
                      child: Text(
                        "Camera Demo",
                      )),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(child: Container()),
                FlatButton(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.brightness_1,
                        size: 80,
                        color: Colors.redAccent,
                      ),
                      enableTakePhoto
                          ? Container()
                          : CupertinoActivityIndicator(
                        radius: 15,
                      ),
                    ],
                  ),
                  onPressed: enableTakePhoto
                      ? () {
                    if (widget.isRecordVideo) {
                      CameraAlbum.startRecord();
                      Future.delayed(Duration(seconds: 5), () {
                        CameraAlbum.stopRecord();
                      });
                      return;
                    }
                    CameraAlbum.takePhoto(takeStart: () {
                      debugPrint("takeStart");
                      setState(() {
                        enableTakePhoto = false;
                      });
                    }, completion: (path) async {
                      debugPrint(path);
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return NewPage(MediaType.image, [path]);
                          }));
                      setState(() {
                        enableTakePhoto = true;
                      });
                      CameraAlbum.startCamera();
                    });
                  }
                      : null,
                ),
                Expanded(
                  child: FlatButton(
                    child: Icon(
                      Icons.switch_camera,
                      size: 30,
                    ),
                    onPressed: () {
                      CameraAlbum.switchCamera();
                    },
                  ),
                )
              ],
            ),
          ],
        ));
  }
}

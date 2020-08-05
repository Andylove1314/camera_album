import 'package:camera_album/camera_album.dart';
import 'package:camera_album/view_camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'newpage.dart';

class AndroidCameraPage extends StatefulWidget {
  @override
  _AndroidCameraPzgeState createState() => _AndroidCameraPzgeState();
}

class _AndroidCameraPzgeState extends State<AndroidCameraPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.flash_off),
              onPressed: () {
                CameraAlbum.setFlashMode(CaptureDeviceFlashMode.on);
              })
        ],
      ),
      body: AndroidViewCamera(),
      bottomNavigationBar: GestureDetector(
        child: Container(
          height: 100.0,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              ///拍照
              IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () {
                    CameraAlbum.takePhoto(
                        takeStart: () {}, completion: (str) {

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return NewPage(
                              MediaType.image,
                              [str],
                            );
                          }));

                    });
                  }),

              Container(width: 2.0,height:100.0,color: Colors.red,),

              ///录视频
              IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () {
                    CameraAlbum.startRecord();
                  }),
              ///结束录视频
              IconButton(
                  icon: Icon(Icons.music_video),
                  onPressed: () {
                    CameraAlbum.stopRecord(onRecodeDone: (str){

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return NewPage(
                              MediaType.video,
                              [str],
                            );
                          }));


                    });
                  }),
              ///切换相机前后摄像头
              Expanded(child: Container(child: IconButton(
                  icon: Icon(Icons.camera_front),
                  onPressed: () {
                    CameraAlbum.switchCamera();
                  }),alignment: Alignment.centerRight,margin: EdgeInsets.only(right: 10.0),),flex: 1,),

            ],
          ),
        ),
        onTap: () {},
      ),
    );
  }
}

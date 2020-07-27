import 'dart:async';
import 'dart:io';

import 'package:camera_album/ui_kit_album.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'album_picker.dart';
export 'ui_kit_album.dart';

class CameraAlbum {
  static const MethodChannel _channel =
      const MethodChannel('flutter/camera_album');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  ///打开相册插件
  static Future<String> openAlbum(Map<String, dynamic> business,
      {BuildContext context,
      MediaType mediaType = MediaType.image,
      callback}) async {
    ///回调监听
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onMessage":
          var backs = call.arguments;
          print('native回传数据：$backs');
          callback(backs);
          return null;
        default:
          throw UnsupportedError("Unrecognized JSON message");
      }
    });

    if (Platform.isIOS) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AlbumPicker(
          title: business["title"],
          mediaType: mediaType,
          onSelected: (path) {
            callback({
              "paths": [path]
            });
          },
        );
      }));
      return "";
    }

    return _channel.invokeMethod('openAlbum', business);
  }

  static Future requestImageFile({@required identifier}) {
    return _channel
        .invokeMethod("requestImageFile", {"identifier": identifier});
  }

  static Future requestVideoFile({@required identifier}) {
    return _channel
        .invokeMethod("requestVideoFile", {"identifier": identifier});
  }
}

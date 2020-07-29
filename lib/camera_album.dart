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
      {BuildContext context, callback}) async {
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

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        MediaType mediaType =
            business["inType"] == "image" ? MediaType.image : MediaType.video;
        return AlbumPicker(
          title: business["title"],
          limit: business["multiCount"],
          mediaType: mediaType,
          onSelected: (path, seconds) {
            callback({
              "paths": path,
              "durs": seconds,
            });
          },
        );
      }));
      return "";
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

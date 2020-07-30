import 'dart:async';
import 'dart:io';

import 'package:camera_album/ui_kit_album.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'album_picker.dart';
export 'ui_kit_album.dart';
export 'ui_kit_camera.dart';

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
      callback,
      void Function(List identifier, List duration) onChanged,
      VoidCallback onLimitCallback,
      bool androidView = true}) async {
    ///回调监听
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onMessage":
          var backs = call.arguments;
          print('native回传数据：$backs');
          callback(backs);
          return null;
        case "onSelected":
          var identifier = call.arguments["identifier"];
          var duration = call.arguments["duration"];
          onChanged(identifier, duration);
          print('native回传数据：${call.arguments}');
          return null;
        case "onLimitCallback":
          onLimitCallback();
          return null;
        default:
          throw UnsupportedError("Unrecognized JSON message");
      }
    });

    if(Platform.isIOS || androidView){
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        MediaType mediaType =
        business["inType"] == "image" ? MediaType.image : MediaType.video;
        bool isMulti = business["isMulti"];
        return AlbumPicker(
          title: business["title"],
          limit: isMulti ? business["multiCount"] : 1,
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
    }else{
      _channel.invokeMethod('openAlbum', business);
    }
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

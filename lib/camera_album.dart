import 'dart:async';

import 'package:flutter/services.dart';

class CameraAlbum {
  static const MethodChannel _channel =
      const MethodChannel('flutter/camera_album');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  ///打开相册插件
  static Future<String> openAlbum(Map<String, dynamic> business,{callback}) async {

    ///回调监听
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {

        case "onMessage":
          String path = '${call.arguments}';
          print('回传数据：$path');
          callback(path);
          return null;
        default:
          throw UnsupportedError("Unrecognized JSON message");
      }
    });

    return _channel.invokeMethod('openAlbum',business);
  }

}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CameraAlbum {
  static const MethodChannel _channel =
      const MethodChannel('flutter/camera_album');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static selectImageBlock(ValueChanged<dynamic> d) async {
    _channel.setMethodCallHandler((call) {
      d("${call.arguments}");
      return;
    });
  }
}

import 'dart:async';
import 'dart:io';

import 'package:camera_album/camera_album_config.dart';
import 'package:camera_album/ui_kit_album.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'album_picker.dart';
export 'ui_kit_album.dart';
export 'ui_kit_camera.dart';
export 'camera_album_config.dart';

class CameraAlbum {
  ///channel
  static const MethodChannel _channel =
      const MethodChannel('flutter/camera_album');

  ///callback
  static const String method_onMessage = 'onMessage';
  static const String method_onSelected = 'onSelected';
  static const String method_onLimitCallback = 'onLimitCallback';

  /// call
  static const String method_openAlbum = 'openAlbum';
  static const String method_requestImageFile = 'requestImageFile';
  static const String method_requestVideoFile = 'requestVideoFile';

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  ///打开相册插件
  static Future<String> openAlbum(
      {@required CameraAlbumConfig config,
      BuildContext context,
      Function(CameraAlbumBack back) callback,
      void Function(List identifier, List duration) onChanged,
      VoidCallback onLimitCallback,
      bool androidView = true}) async {

    ///回调监听
    _channel.setMethodCallHandler((MethodCall call) async {
      var method = call.method;
      var backs = call.arguments;
      print('native回传：$method -> $backs');
      switch (method) {
        case method_onMessage:
          var paths = backs["paths"];
          var durs = backs["durs"];
          callback(CameraAlbumBack(paths:paths,durs: durs));
          return null;
        case method_onSelected:
          var paths = backs["paths"];
          var durs = backs["durs"];
          onChanged(paths, durs);
          return null;
        case method_onLimitCallback:
          onLimitCallback();
          return null;
        default:
          throw UnsupportedError("Unrecognized JSON message");
      }
    });

    if(config == null){
      return '';
    }

    if (Platform.isIOS || androidView) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        MediaType mediaType =
        config.inType == "image" ? MediaType.image : MediaType.video;
        bool isMulti = config.isMulti;
        return AlbumPicker(
          title: config.title,
          limit: isMulti ? config.multiCount : 1,
          mediaType: mediaType,
          onSelected: (paths, seconds) {
            callback(CameraAlbumBack(paths: paths, durs: seconds));
          },
        );
      }));
      return "";
    } else {
      return _channel.invokeMethod(method_openAlbum, config.toMap());
    }
  }

  static Future requestImageFile({@required identifier}) {
    return _channel
        .invokeMethod(method_requestImageFile, {"identifier": identifier});
  }

  static Future requestVideoFile({@required identifier}) {
    return _channel
        .invokeMethod(method_requestVideoFile, {"identifier": identifier});
  }
}

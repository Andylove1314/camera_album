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
export 'package:camera_album/view_camera.dart';

/*
    off = 0
    on = 1
    auto = 2
     */

/// 闪光灯模式
enum CaptureDeviceFlashMode {
  off,
  on,
  auto,
}

class CameraAlbum {
  ///channel
  static const MethodChannel _channel =
      const MethodChannel('flutter/camera_album');

  ///callback
  static const String method_onMessage = 'onMessage';
  static const String method_onSelected = 'onSelected';
  static const String method_onLimitCallback = 'onLimitCallback';
  static const String method_callCamera = 'callCamera';

  /// call
  static const String method_openAlbum = 'openAlbum';
  static const String method_requestImagePreview = 'requestImagePreview';
  static const String method_requestImageFile = 'requestImageFile';
  static const String method_requestVideoFile = 'requestVideoFile';
  static const String method_requestLastImage = 'requestLastImage';
  static const String method_switchCamera = 'switchCamera';
  static const String method_setFlashMode = 'setFlashMode';
  static const String method_startCamera = 'startCamera';

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  ///打开相册插件
  static Future<String> openAlbum({
    @required CameraAlbumConfig config,
    /// 返回按钮样式可以不传
    Widget leading,
    BuildContext context,
    Function(CameraAlbumBack back) callback,
    void Function(List identifier, List duration) onChanged,
    VoidCallback onLimitCallback,
    bool androidView = false,
    Function() callCamera,
  }) async {
    ///回调监听
    _channel.setMethodCallHandler((MethodCall call) async {
      var method = call.method;
      var backs = call.arguments;
      print('native回传：$method -> $backs');
      switch (method) {
        case method_onMessage:
          var paths = backs["paths"];
          var durs = backs["durs"];
          callback(CameraAlbumBack(paths: paths, durs: durs));
          return null;
        case method_onSelected:
          var paths = backs["paths"];
          var durs = backs["durs"];
          onChanged(paths, durs);
          return null;
        case method_onLimitCallback:
          onLimitCallback();
          return null;
        case method_callCamera:
          if (callCamera != null) {
            callCamera();
          }
          return null;
        default:
          throw UnsupportedError("Unrecognized JSON message");
      }
    });

    if (config == null) {
      return '';
    }

    if (Platform.isIOS || androidView) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        MediaType mediaType =
            config.inType == "image" ? MediaType.image : MediaType.video;
        bool isMulti = config.isMulti;
        return AlbumPicker(
          leading: leading,
          config: config,
          androidView: androidView,
          title: config.title,
          doneTitle: config.doneTitle,
          limit: isMulti ? config.multiCount : 1,
          mediaType: mediaType,
          onSelected: (paths, seconds) {
            callback(CameraAlbumBack(paths: paths, durs: seconds));
          },
          onLimitCallback: onLimitCallback,
        );
      }));
      return "";
    } else {
      return _channel.invokeMethod(method_openAlbum, config.toMap());
    }
  }

  static Future requestImagePreview({@required identifier}) {
    return _channel
        .invokeMethod(method_requestImagePreview, {"identifier": identifier});
  }

  static Future requestImageFile({@required identifier}) {
    return _channel
        .invokeMethod(method_requestImageFile, {"identifier": identifier});
  }

  static Future requestVideoFile({@required identifier}) {
    return _channel
        .invokeMethod(method_requestVideoFile, {"identifier": identifier});
  }

  static Future requestLastImage(String type) {
    return _channel.invokeMethod(method_requestLastImage, {"type": type});
  }

  /// 开始预览
  static Future startCamera() {
    return _channel.invokeMethod(method_startCamera);
  }

  /// 切换摄像头
  static Future switchCamera() {
    return _channel.invokeMethod(method_switchCamera);
  }

  /// 切换闪光灯
  static Future setFlashMode(CaptureDeviceFlashMode mode) {
    return _channel.invokeMethod(method_setFlashMode, mode.index);
  }

  /// 拍照片
  static void takePhoto(
      {VoidCallback takeStart, void Function(String path) completion}) async {
    _channel.invokeMethod("takePhoto");

    ///回调监听
    _channel.setMethodCallHandler((MethodCall call) async {
      var method = call.method;
      var backs = call.arguments;
      print('native回传：$method -> $backs');
      switch (method) {
        case "onTakeStart":
          takeStart();
          break;
        case "onTakeDone":
          if(Platform.isIOS){
            var identifier = backs["identifier"];
            String path = await CameraAlbum.requestImageFile(identifier: identifier);
            completion(path);
          }else{
            completion(backs);
          }
          break;
        default:
          throw UnsupportedError("Unrecognized JSON message");
      }
    });
  }

  /// 开始录制视频
  static void startRecord() async {
    _channel.invokeMethod("startRecord");
  }

  /// 结束录制视频
  static void stopRecord(
      {VoidCallback onRecordStart,
      void Function(String path) onRecodeDone}) async {
    _channel.invokeMethod("stopRecord");

    ///回调监听
    _channel.setMethodCallHandler((MethodCall call) async {
      var method = call.method;
      var back = call.arguments;
      print('native回传：$method -> $back');
      switch (method) {
        case "onRecordStart":
          onRecordStart();
          break;
        case "onRecodeDone":

          if(Platform.isIOS){
            String path = back["path"];
            onRecodeDone(path);
          }else{
            onRecodeDone(back);
          }

          break;
        default:
          throw UnsupportedError("Unrecognized JSON message");
      }
    });
  }
}

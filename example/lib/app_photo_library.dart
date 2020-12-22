import 'package:camera_album/camera_album.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppPhotoLibrary {
  static const _channel = const MethodChannel("com.bigwinepot/nwdn");

  static const String _method_showPhotoLibrary = 'showPhotoLibrary';
  static const String _method_onSelectedHandler = 'onSelectedHandler';
  static const String _method_callCamera = 'callCamera';

  AppPhotoLibrary._();

  /// 直接进入相册选择
  static void showPhotoLibrary(
      {MediaType mediaType = MediaType.image,
      int maxSelectCount = 1,
      String taskTitle = "",
      String takeTitle = "",
      String data,
      void Function(List<CameraAlbumModel>) onSelected,
      VoidCallback openCamera}) async {
    _channel.setMethodCallHandler((MethodCall call) async {
      String method = call.method;
      Map arguments = call.arguments;
      print('$method -> $arguments');
      switch (method) {
        case _method_onSelectedHandler:
          if (maxSelectCount > 1) {
            List originPaths = arguments["paths"];
            List previewPaths = arguments["previewPaths"];
            List durations = arguments["durations"];

            List<CameraAlbumModel> list = [];
            for (int index = 0; index < originPaths.length; index++) {
              list.add(
                CameraAlbumModel()
                  ..originPath = originPaths?.isNotEmpty == true
                      ? '${originPaths[index]}'
                      : ''
                  ..previewPath = previewPaths?.isNotEmpty == true
                      ? '${previewPaths[index]}'
                      : ''
                  ..duration = durations?.isNotEmpty == true
                      ? durations[index] as double
                      : 0,
              );
            }
            onSelected(list);
          }
          break;
        case _method_callCamera:
          if (openCamera != null) {
            openCamera();
          }
          break;
        default:
          throw UnsupportedError("Unrecognized JSON message");
      }
    });
    _channel.invokeMethod(_method_showPhotoLibrary, {
      'mediaType': mediaType.index,
      'maxSelectCount': maxSelectCount,
      'taskTitle': taskTitle,
      'takeTitle': takeTitle,
      'data': data,
    });
  }
}

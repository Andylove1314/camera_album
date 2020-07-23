import 'package:camera_album/camera_album.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UIKitAlbum extends StatefulWidget {
  final ValueChanged callback;

  const UIKitAlbum({Key key, this.callback}) : super(key: key);

  @override
  _UIKitAlbumState createState() => _UIKitAlbumState();
}

class _UIKitAlbumState extends State<UIKitAlbum> {

  @override
  void initState() {
    CameraAlbum.openAlbum(null, callback: widget.callback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (c, cc) {
          return UiKitView(
            viewType: "platform_gallery_view",
            creationParams: <String, dynamic>{
              "text": "选照片",
            },
            creationParamsCodec: const StandardMessageCodec(),
          );
        },
      ),
    );
  }
}

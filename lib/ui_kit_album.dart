import 'dart:io';

import 'package:camera_album/camera_album.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MediaType {
  unknown, // 0
  image, // 1
  video, // 2
  audio, // 3
}

class UIKitAlbum extends StatefulWidget {
  final MediaType mediaType;
  final int limit;
  final ValueChanged callback;
  final void Function(List identifier, List duration) onChanged;

  const UIKitAlbum(
      {Key key,
      @required this.mediaType,
      this.limit = 1,
      this.callback,
      this.onChanged})
      : super(key: key);

  @override
  _UIKitAlbumState createState() => _UIKitAlbumState();
}

class _UIKitAlbumState extends State<UIKitAlbum> {
  @override
  void initState() {
    CameraAlbum.openAlbum(null,
        callback: widget.callback, onChanged: widget.onChanged);
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
              "mediaType": widget.mediaType.index,
              "limit": widget.limit,
            },
            creationParamsCodec: const StandardMessageCodec(),
          );
        },
      ),
    );
  }
}

class UIKitRequestImage extends StatefulWidget {
  final MediaType mediaType;
  final String identifier;
  final ValueChanged onDone;
  final Widget child;

  const UIKitRequestImage(
      {Key key,
      this.mediaType = MediaType.image,
      @required this.identifier,
      this.onDone,
      this.child})
      : super(key: key);

  @override
  _UIKitRequestImageState createState() => _UIKitRequestImageState();
}

class _UIKitRequestImageState extends State<UIKitRequestImage> {
  @override
  void initState() {
    if (widget.mediaType == MediaType.image) {
      CameraAlbum.requestImageFile(identifier: widget.identifier).then((value) {
        widget.onDone(File(value));
      });
    } else if (widget.mediaType == MediaType.video) {
      CameraAlbum.requestVideoFile(identifier: widget.identifier).then((value) {
        widget.onDone(File(value));
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

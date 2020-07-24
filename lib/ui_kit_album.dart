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
  final ValueChanged callback;

  const UIKitAlbum({Key key, @required this.mediaType, this.callback})
      : super(key: key);

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
              "mediaType": widget.mediaType.index
            },
            creationParamsCodec: const StandardMessageCodec(),
          );
        },
      ),
    );
  }
}

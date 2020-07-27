import 'package:flutter/material.dart';

import 'camera_album.dart';
import 'ui_kit_album.dart';

class AlbumPicker extends StatefulWidget {
  final String title;
  final MediaType mediaType;
  final void Function(String path) onSelected;

  const AlbumPicker(
      {Key key, this.title = "", @required this.mediaType, this.onSelected})
      : super(key: key);

  @override
  _AlbumPickerState createState() => _AlbumPickerState();
}

class _AlbumPickerState extends State<AlbumPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 5),
        child: UIKitAlbum(
          mediaType: widget.mediaType,
          callback: (info) async {
            var identifiers = info['identifier'];
            int seconds = 0;
            String path = "";
            if (widget.mediaType == MediaType.video) {
              path = await CameraAlbum.requestVideoFile(
                  identifier: identifiers.first);
              double duration = info['duration'].first ?? 0;
              seconds = duration.toInt();
            } else if (widget.mediaType == MediaType.image) {
              path = await CameraAlbum.requestImageFile(
                  identifier: identifiers.first);
            }
            Navigator.pop(context);
            widget.onSelected(path);
          },
        ),
      ),
    );
  }
}

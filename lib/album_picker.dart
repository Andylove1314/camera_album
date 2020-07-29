import 'dart:io';

import 'package:flutter/material.dart';

import 'camera_album.dart';
import 'ui_kit_album.dart';

class AlbumPicker extends StatefulWidget {
  final String title;
  final int limit;
  final MediaType mediaType;
  final void Function(List<dynamic> path, List<dynamic> seconds) onSelected;

  const AlbumPicker(
      {Key key,
      this.title = "",
      this.limit = 1,
      @required this.mediaType,
      this.onSelected})
      : super(key: key);

  @override
  _AlbumPickerState createState() => _AlbumPickerState();
}

class _AlbumPickerState extends State<AlbumPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 5),
        child: UIKitAlbum(
          mediaType: widget.mediaType,
          limit: widget.limit,
          callback: (info) async {
            print(info);

            if(Platform.isIOS){
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
              widget.onSelected([path], [seconds]);
            }else{
//              Navigator.pop(context);
              widget.onSelected(info['paths'], info['durs']);
            }


          },
        ),
      ),
    );
  }
}

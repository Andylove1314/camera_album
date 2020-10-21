import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'camera_album.dart';
import 'ui_kit_album.dart';

class AlbumPicker extends StatefulWidget {
  final Widget leading;
  final String title;
  final String doneTitle;
  final int limit;
  final MediaType mediaType;
  final void Function(List<dynamic> path, List<dynamic> seconds) onSelected;
  final VoidCallback onLimitCallback;
  final CameraAlbumConfig config;
  final bool androidView;

  const AlbumPicker(
      {Key key,
      this.leading,
      this.title = "",
      this.limit = 1,
      @required this.mediaType,
      this.onSelected,
      this.onLimitCallback,
      this.config,
      this.androidView = false,
      this.doneTitle})
      : super(key: key);

  @override
  _AlbumPickerState createState() => _AlbumPickerState();
}

class _AlbumPickerState extends State<AlbumPicker> {
  List identifier = [];
  List duration = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.leading ?? null,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: widget.limit == 1
            ? null
            : <Widget>[
                FlatButton(
                    onPressed: () async {
                      List<String> pathList = [];
                      List<int> durationList = [];

                      for (int index = 0; index < identifier.length; index++) {
                        String path = (widget.mediaType == MediaType.video
                            ? await CameraAlbum.requestVideoFile(
                                identifier: identifier[index])
                            : await CameraAlbum.requestImageFile(
                                identifier: identifier[index]));
                        pathList.add(path);
                        int seconds = duration[index].toInt();
                        durationList.add(seconds);
                      }
                      Navigator.pop(context);
                      widget.onSelected(pathList, durationList);
                    },
                    child: Platform.isIOS
                        ? Text(
                            "${widget.doneTitle ?? 'Done'}(${identifier.length})",
                            style: TextStyle(color: Color(0xffF04B42)),
                          )
                        : SizedBox())
              ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 5),
        child: UIKitAlbum(
          mediaType: widget.mediaType,
          limit: widget.limit,
          callback: (info) async {
            print(info);

            if (Platform.isIOS) {
              var identifiers = info.paths;
              int seconds = 0;
              String path = "";
              if (widget.mediaType == MediaType.video) {
                path = await CameraAlbum.requestVideoFile(
                    identifier: identifiers.first);
                double duration = info.durs.first ?? 0;
                seconds = duration.toInt();
              } else if (widget.mediaType == MediaType.image) {
                path = await CameraAlbum.requestImageFile(
                    identifier: identifiers.first);
              }
              Navigator.pop(context);
              widget.onSelected([path], [seconds]);
            } else {
              if (widget.androidView) {
                Navigator.pop(context);
              }
              widget.onSelected(info.paths, info.durs);
            }
          },
          onChanged: (List identifier, List duration) {
            this.identifier = identifier;
            this.duration = duration;
            setState(() {});
          },
          onLimitCallback: widget.onLimitCallback,
          config: widget.config,
        ),
      ),
    );
  }
}

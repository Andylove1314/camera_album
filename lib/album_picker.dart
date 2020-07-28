import 'package:flutter/material.dart';

import 'camera_album.dart';
import 'ui_kit_album.dart';

class AlbumPicker extends StatefulWidget {
  final String title;
  final int limit;
  final MediaType mediaType;
  final void Function(List<String> path, List<int> seconds) onSelected;

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
  List identifier = [];
  List duration = [];

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
        actions: <Widget>[
          FlatButton(
              onPressed: () async {
//                widget.onSelected(identifier.map((e) => "$e").toList(),
//                    duration.map((e) => int.tryParse("$e")).toList());

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
              child: Text("Done(${identifier.length})"))
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 5),
        child: UIKitAlbum(
          mediaType: widget.mediaType,
          limit: widget.limit,
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
            widget.onSelected([path], [seconds]);
          },
          onChanged: (List identifier, List duration) {
            this.identifier = identifier;
            this.duration = duration;
            setState(() {});
          },
        ),
      ),
    );
  }
}

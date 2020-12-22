import 'dart:io';
import 'dart:ui';

import 'package:camera_album/camera_album.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thrio/thrio.dart';
import 'package:video_player/video_player.dart';

class NewPage extends StatefulWidget {
  List paths;
  List durs;
  List previewPaths;
  MediaType mediaType;

  NewPage(this.mediaType, this.paths, {this.durs, this.previewPaths});

  @override
  _NewPagePageState createState() => _NewPagePageState();
}

class _NewPagePageState extends State<NewPage> {
  /// channel
  static const MethodChannel _channel =
      const MethodChannel('edit_page_channel');

  @override
  void initState() {
    _channel.setMethodCallHandler((call) {
      String method = call.method;
      Map arguments = call.arguments;
      print('${_channel.name} -> $method -> $arguments');
      if (call.method == "selected") {
        int mediaType = arguments['mediaType'];
        List originPaths = arguments["paths"];
        List previewPaths = arguments["previewPaths"];
        List durations = arguments["durations"];

        List<CameraAlbumModel> list = [];
        for (int index = 0; index < originPaths.length; index++) {
          list.add(
            CameraAlbumModel()
              ..originPath =
                  originPaths?.isNotEmpty == true ? '${originPaths[index]}' : ''
              ..previewPath = previewPaths?.isNotEmpty == true
                  ? '${previewPaths[index]}'
                  : ''
              ..duration = durations?.isNotEmpty == true
                  ? durations[index] as double
                  : 0,
          );
        }
        widget.mediaType = mediaType == 1
            ? MediaType.image
            : mediaType == 2
                ? MediaType.video
                : MediaType.unknown;
        widget.paths = originPaths;
        widget.previewPaths = previewPaths;
        widget.durs = durations;
        setState(() {});
      }
      return;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            try {
              ThrioNavigator.pop();
            } catch (e) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: widget.mediaType == MediaType.unknown
              ? Text('unknown')
              : Column(
                  children: widget.mediaType == MediaType.video
                      ? widget.paths
                          .map((e) => VideoPlay(file: File(e)))
                          .toList()
                      : _getImages(),
                ),
        ),
      ),
    );
  }

  List<Widget> _getImages() {
    var images = List<Widget>();
    if (widget.previewPaths != null) {
      widget?.previewPaths?.forEach((path) {
        images.add(Stack(
          alignment: Alignment.center,
          children: [
            Image.file(File(path)),
            RaisedButton(
              color: Colors.green,
              child: Text("预览图"),
              onPressed: () {},
            ),
          ],
        ));
      });
    } else {
      widget?.paths?.forEach((path) {
        images.add(Stack(
          alignment: Alignment.center,
          children: [
            Image.file(File(path)),
            RaisedButton(
              color: Colors.red,
              child: Text("源图"),
              onPressed: () {},
            ),
          ],
        ));
      });
    }
    return images;
  }
}

class VideoPlay extends StatefulWidget {
  final File file;

  const VideoPlay({Key key, this.file}) : super(key: key);

  @override
  _VideoPlayState createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.file(widget.file);
    _controller.initialize().then((value) {
      _controller.play();
      _controller.setLooping(true);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: (_controller == null || !_controller.value.initialized)
          ? Text("initialized...")
          : AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
    );
  }
}

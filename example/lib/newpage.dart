import 'dart:io';
import 'dart:ui';

import 'package:camera_album/camera_album.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NewPage extends StatefulWidget {
  List paths;
  List durs;
  MediaType mediaType;

  NewPage(this.mediaType, this.paths,{this.durs});

  @override
  _NewPagePageState createState() => _NewPagePageState();
}

class _NewPagePageState extends State<NewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: widget.mediaType == MediaType.video
                  ? _getVideos()
                  : _getImages(),
            ),
          ),
        ));
  }

  List<Widget> _getVideos() {
    var images = List<Widget>();
    widget?.paths?.forEach((path) {
      images.add(VideoPlay(file: File(path)));
    });
    return images;
  }

  List<Widget> _getImages() {
    var images = List<Widget>();
    widget?.paths?.forEach((path) {
      images.add(Image.file(File(path)));
    });
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

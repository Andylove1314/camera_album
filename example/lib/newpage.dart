import 'dart:io';
import 'dart:ui';

import 'package:camera_album/camera_album.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NewPage extends StatefulWidget {
  List paths;
  MediaType mediaType;

  NewPage(this.mediaType, this.paths);

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
              children: _getImages(),
            ),
          ),
        ));
  }

  List<Widget> _getImages() {
    var images = List<Widget>();
    widget?.paths?.forEach((path) {
      images.add(Platform.isIOS
          ? RequestImage(
              mediaType: widget.mediaType,
              identifier: path,
            )
          : Image.file(File(path)));
    });
    return images;
  }
}

class RequestImage extends StatefulWidget {
  final MediaType mediaType;
  final String identifier;

  const RequestImage(
      {Key key, this.mediaType = MediaType.image, this.identifier})
      : super(key: key);

  @override
  _RequestImageState createState() => _RequestImageState();
}

class _RequestImageState extends State<RequestImage> {
  File _file;

  VideoPlayerController _controller;

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UIKitRequestImage(
      mediaType: widget.mediaType,
      identifier: widget.identifier,
      onDone: (file) {
        setState(
          () {
            _file = file;
            if (widget.mediaType == MediaType.video) {
              _controller = VideoPlayerController.file(file);
              _controller.initialize().then((value) {
                _controller.play();
                setState(() {});
              });
            } else {
              setState(() {});
            }
          },
        );
      },
      child: Builder(
        builder: (BuildContext context) {
          if (_file == null) {
            return CupertinoActivityIndicator();
          } else {
            if (widget.mediaType == MediaType.video) {
              return Container(
                color: Colors.black,
                child: (_controller == null || !_controller.value.initialized)
                    ? Text("initialized...")
                    : AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
              );
            } else {
              return Image.file(_file);
            }
          }
        },
      ),
    );
  }
}

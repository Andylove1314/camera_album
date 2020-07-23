import 'dart:io';
import 'dart:ui';

import 'package:camera_album/camera_album.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewPage extends StatefulWidget {
  List paths;

  NewPage(this.paths);

  @override
  _NewPagePageState createState() => _NewPagePageState();
}

class _NewPagePageState extends State<NewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.red,
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
              identifier: path,
            )
          : Image.file(File(path)));
    });
    return images;
  }
}

class RequestImage extends StatefulWidget {
  final String identifier;

  const RequestImage({Key key, this.identifier}) : super(key: key);

  @override
  _RequestImageState createState() => _RequestImageState();
}

class _RequestImageState extends State<RequestImage> {
  var _image;

  @override
  void initState() {
    CameraAlbum.requestImage(identifier: widget.identifier).then((value) {
      setState(() {
        _image = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _image == null ? CupertinoActivityIndicator() : Image.memory(_image);
  }
}

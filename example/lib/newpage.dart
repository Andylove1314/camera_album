import 'dart:io';
import 'dart:ui';

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
          child: SingleChildScrollView(child: Column(children: _getImages(),),),
        ));
  }

 List<Widget> _getImages(){
    var images = List<Widget>();
    widget?.paths?.forEach((path) {

      images.add(Image.file(File(path)));

    });
    return images;
  }

}


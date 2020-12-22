import 'package:camera_album/camera_album.dart';
import 'package:camera_album_example/home.dart';
import 'package:camera_album_example/newpage.dart';
import 'package:flutter/material.dart' hide Router;

import 'package:fluro/fluro.dart';

class Routes {
  Routes._();

  static String home = '/';
  static String editPage = '/editPage';

  static void configureRouters() {
    Router.appRouter.define(home, handler: rootHandler);
    Router.appRouter.define(editPage, handler: editPageHandler);

    Router.appRouter.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Content not found'),
        ),
        body: Center(
          child: Text('Sorry,Content not found'),
        ),
      );
    });
  }
}

var rootHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return Home();
});

var editPageHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return NewPage(MediaType.unknown, []);
});

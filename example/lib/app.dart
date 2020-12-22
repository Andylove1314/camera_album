import 'package:camera_album/camera_album.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thrio/thrio.dart';

import 'newpage.dart';
import 'routes/routes.dart';
import 'package:fluro/fluro.dart' as fluro;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    ThrioModule.init(Module(), "main");

    /// 配置路由
    Routes.configureRouters();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: NavigatorMaterialApp(
        home: MaterialApp(
          onGenerateRoute: fluro.Router.appRouter.generator,
        ),
      ),
    );
  }
}

class Module with ThrioModule {
  @override
  void onModuleRegister(ModuleContext moduleContext) {
    registerModule(ImageEditModule(), moduleContext);
  }

  @override
  void onModuleInit(ModuleContext moduleContext) {
    navigatorLogEnabled = true;
  }
}

class ImageEditModule
    with
        ThrioModule,
        ModulePageBuilder,
        ModulePageObserver,
        ModuleRouteTransitionsBuilder,
        NavigatorPageObserver {
  @override
  String get key => "image_edit";

  @override
  void onPageBuilderSetting(ModuleContext moduleContext) {
    pageBuilder = (settings) {

      Map arguments = settings.arguments;
      Map params = arguments["params"];
      int mediaType = params['mediaType'];
      List originPaths = params["paths"];
      List previewPaths = params["previewPaths"];
      List durations = params["durations"];

      List<CameraAlbumModel> list = [];
      for (int index = 0; index < originPaths.length; index++) {
        list.add(
          CameraAlbumModel()
            ..originPath = originPaths?.isNotEmpty == true
                ? '${originPaths[index]}'
                : ''
            ..previewPath = previewPaths?.isNotEmpty == true
                ? '${previewPaths[index]}'
                : ''
            ..duration = durations?.isNotEmpty == true
                ? durations[index] as double
                : 0,
        );
      }

      return NewPage(
        mediaType == 1
            ? MediaType.image
            : mediaType == 2
            ? MediaType.video
            : MediaType.unknown,
        list.map((e) => e.originPath).toList(),
        previewPaths: list.map((e) => e.previewPath).toList(),
      );
    };
  }

  @override
  void onPageObserverRegister(ModuleContext moduleContext) {
    registerPageObserver(this);
  }

  @override
  void onRouteTransitionsBuilderSetting(ModuleContext moduleContext) {
    routeTransitionsBuilder = (
      context,
      animation,
      secondaryAnimation,
      child,
    ) =>
        SlideTransition(
          transformHitTests: false,
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0, 1),
            ).animate(secondaryAnimation),
            child: child,
          ),
        );
  }

  @override
  void didAppear(RouteSettings routeSettings) {
    ThrioLogger.v('image_edit didAppear: $routeSettings');
  }

  @override
  void didDisappear(RouteSettings routeSettings) {
    ThrioLogger.v('image_edit didDisappear: $routeSettings');
  }

  @override
  void willAppear(RouteSettings routeSettings) {
    ThrioLogger.v('image_edit willAppear: $routeSettings');
  }

  @override
  void willDisappear(RouteSettings routeSettings) {
    ThrioLogger.v('image_edit willDisappear: $routeSettings');
  }
}

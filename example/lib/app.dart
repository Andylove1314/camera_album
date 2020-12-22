import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thrio/thrio.dart';

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
    registerModule(ModuleEditPage(), moduleContext);
  }

  @override
  void onModuleInit(ModuleContext moduleContext) {
    navigatorLogEnabled = true;
  }
}

class ModuleEditPage
    with
        ThrioModule,
        ModulePageBuilder,
        ModulePageObserver,
        ModuleRouteTransitionsBuilder,
        NavigatorPageObserver {
  @override
  String get key => "edit_page";

  @override
  void onPageBuilderSetting(ModuleContext moduleContext) {
    pageBuilder = (settings) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              ThrioNavigator.pop();
            },
          ),
        ),
        backgroundColor: Colors.blue,
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
    ThrioLogger.v('biz1 didAppear: $routeSettings');
  }

  @override
  void didDisappear(RouteSettings routeSettings) {
    ThrioLogger.v('biz1 didDisappear: $routeSettings');
  }

  @override
  void willAppear(RouteSettings routeSettings) {
    ThrioLogger.v('biz1 willAppear: $routeSettings');
  }

  @override
  void willDisappear(RouteSettings routeSettings) {
    ThrioLogger.v('biz1 willDisappear: $routeSettings');
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UIKitCamera extends StatefulWidget {
  @override
  _UIKitCameraState createState() => _UIKitCameraState();
}

class _UIKitCameraState extends State<UIKitCamera> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (c, cc) {
          return UiKitView(
            viewType: "platform_camera_view",
            creationParams: <String, dynamic>{
              "appBarHeight": kToolbarHeight,
              /*
              case back = 1
              case front = 2
              */
              "position": 2,
            },
            creationParamsCodec: const StandardMessageCodec(),
          );
        },
      ),
    );
  }
}

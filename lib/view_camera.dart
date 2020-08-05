import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AndroidViewCamera extends StatefulWidget {
  @override
  _AndroidViewCameraState createState() => _AndroidViewCameraState();
}

class _AndroidViewCameraState extends State<AndroidViewCamera> {

  @override
  Widget build(BuildContext context) {
    return AndroidView(
        viewType: "platform_gallery_view2",
        creationParams:{},
        creationParamsCodec: const StandardMessageCodec());
  }
}

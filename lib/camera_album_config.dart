import 'dart:convert';

/// flutter to native
class CameraAlbumConfig {
  var actionId;
  var title;
  var inType;
  var firstCamera;
  var showBottomCamera;
  var showGridCamera;
  var showAlbum;
  var isMulti;
  var guides;
  var multiCount;
  bool cute;
  bool customCamera;

  CameraAlbumConfig(
      {this.actionId,
      this.title,
      this.inType = 'image',
      this.firstCamera = false,
      this.showBottomCamera = true,
      this.showGridCamera = false,
      this.showAlbum = true,
      this.isMulti = false,
      this.guides,
      this.multiCount = 5,
      this.cute = false,
      this.customCamera = false});

  CameraAlbumConfig.from(Map<String, dynamic> data) {
    if (data != null) {
      this.actionId = data['actionId'];
      this.title = data['actiotitlenId'];
      this.inType = data['inType'];
      this.firstCamera = data['firstCamera'];
      this.showBottomCamera = data['showBottomCamera'];
      this.showGridCamera = data['showGridCamera'];
      this.showAlbum = data['showAlbum'];
      this.isMulti = data['isMulti'];
      this.guides = data['guides'];
      this.multiCount = data['multiCount'];
      this.cute = data['cute'];
      this.customCamera = data['customCamera'];
    }
  }

  Map<String, dynamic> toMap() {
    Map map = Map<String, dynamic>();

    map['actionId'] = actionId;
    map['title'] = title;
    map['inType'] = inType;
    map['firstCamera'] = firstCamera;
    map['showBottomCamera'] = showBottomCamera;
    map['showGridCamera'] = showGridCamera;
    map['showAlbum'] = showAlbum;
    map['isMulti'] = isMulti;
    map['guides'] = guides;
    map['multiCount'] = multiCount;
    map['cute'] = cute;
    map['customCamera'] = customCamera;

    return map;
  }

  String toJson() {
    Map map = toMap();

    return json.encode(map);
  }
}

/// native to fluter
class CameraAlbumBack {
  var paths;
  var durs;

  CameraAlbumBack({this.paths, this.durs});

  CameraAlbumBack.from(Map<String, dynamic> data) {
    if (data != null) {
      this.paths = data['paths'];
      this.durs = data['durs'];
    }
  }

  Map<String, dynamic> toMap() {
    Map map = Map<String, dynamic>();

    map['paths'] = paths;
    map['durs'] = durs;

    return map;
  }

  String toJson() {
    Map map = toMap();
    json.encode(map);
  }
}

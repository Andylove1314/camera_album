import Foundation
import Flutter
import Photos

class PlatformCameraViewFactory: NSObject, FlutterPlatformViewFactory {
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return PlatformCameraView(frame,viewID: viewId,args: args)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class PlatformCameraView: NSObject,FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64

    var appBarHeight: CGFloat = 0

    init(_ frame: CGRect, viewID: Int64, args: Any?) {
        self.frame = frame
        self.viewId = viewID
        if (args is NSDictionary) {
            let dict = args as! NSDictionary

            if let limit = dict.value(forKey: "appBarHeight") as? Double {
                self.appBarHeight = CGFloat(limit)
            }
        }
    }
    
    func view() -> UIView {
        return CameraView(frame: UIScreen.main.bounds, appBarHeight: appBarHeight)
    }
}

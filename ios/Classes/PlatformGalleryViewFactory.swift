import Foundation
import Flutter
import Photos

class PlatformGalleryViewFactory: NSObject, FlutterPlatformViewFactory {
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return PlatformGalleryView(frame,viewID: viewId,args: args)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class PlatformGalleryView: NSObject, FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64
    var mediaType: PHAssetMediaType = .unknown
    var limit: Int = 1
    var appBarHeight: CGFloat = 0

    init(_ frame: CGRect, viewID: Int64, args: Any?) {
        self.frame = frame
        self.viewId = viewID
        if (args is NSDictionary) {
            let dict = args as! NSDictionary
            if let mediaType = dict.value(forKey: "mediaType") as? Int {
                self.mediaType = PHAssetMediaType(rawValue: mediaType)!
            }
            if let limit = dict.value(forKey: "limit") as? Int {
                self.limit = limit
            }
            if let limit = dict.value(forKey: "appBarHeight") as? Double {
                self.appBarHeight = CGFloat(limit)
            }
        }
    }
    
    func view() -> UIView {
        return GalleryView(frame: UIScreen.main.bounds, mediaType: mediaType, limit: limit, appBarHeight: appBarHeight)
    }
}

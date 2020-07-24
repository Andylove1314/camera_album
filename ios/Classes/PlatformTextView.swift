import Foundation
import Flutter
import Photos

class PlatformTextViewFactory: NSObject, FlutterPlatformViewFactory {
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return PlatformTextView(frame,viewID: viewId,args: args)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class PlatformTextView: NSObject,FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64
    var mediaType: PHAssetMediaType = .unknown

    init(_ frame: CGRect, viewID: Int64, args: Any?) {
        self.frame = frame
        self.viewId = viewID
        if (args is NSDictionary) {
            let dict = args as! NSDictionary
            if let mediaType = dict.value(forKey: "mediaType") as? Int {
                self.mediaType = PHAssetMediaType(rawValue: mediaType)!
            }
        }
    }
    
    func view() -> UIView {
        return GalleryView(frame: UIScreen.main.bounds, mediaType: mediaType)
    }
}

import Foundation
import Flutter

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
    var text: String = ""

    init(_ frame: CGRect, viewID: Int64, args: Any?) {
        self.frame = frame
        self.viewId = viewID
        if (args is NSDictionary) {
            let dict = args as! NSDictionary
            self.text = dict.value(forKey: "text") as! String
        }
    }
    
    func view() -> UIView {
        return GalleryImageView(frame: UIScreen.main.bounds)
    }
}

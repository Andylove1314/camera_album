import Flutter
import UIKit
import Photos

public class SwiftCameraAlbumPlugin: NSObject, FlutterPlugin {
    
  static var channel: FlutterMethodChannel!
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "flutter/camera_album", binaryMessenger: registrar.messenger())
    
    let factory = PlatformTextViewFactory()
    registrar.register(factory, withId: "platform_gallery_view")
    
    let instance = SwiftCameraAlbumPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestImageData":
        let params = call.arguments as! NSDictionary
        let identifier = params["identifier"] as! String
        if let image = Image.initWith(identifier: identifier) {
        image.resolveImageData { (imageData, info) in
            if let imageData = imageData {
                    result(imageData)
                }
            }
        }
    case "requestVideoFile":
        let params = call.arguments as! NSDictionary
        let identifier = params["identifier"] as! String
        if let video = Video.initWith(identifier: identifier) {
            // https://blog.csdn.net/qq_22157341/article/details/80758683
            if let assetResource = PHAssetResource.assetResources(for: video.asset).first {
            let fileName = assetResource.originalFilename;
                let path = NSTemporaryDirectory() + "temp." + (fileName.components(separatedBy: ".").last ?? "")
                try? FileManager.default.removeItem(atPath: path)
            
            let options = PHAssetResourceRequestOptions()
                options.isNetworkAccessAllowed = true;
            PHAssetResourceManager.default().writeData(for: assetResource, toFile: URL(fileURLWithPath: path), options: options) { (error) in
                if let error = error {
                    print(error);
                } else {
                    result(path)
                }
            }
            }
        }
    default: break
    }
  }
}

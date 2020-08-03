import Flutter
import UIKit
import Photos

private let kNwdnAsset = "nwdn_asset/"
let tmpNwdn = NSTemporaryDirectory() + kNwdnAsset

public class SwiftCameraAlbumPlugin: NSObject, FlutterPlugin {
    
  static var channel: FlutterMethodChannel!
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "flutter/camera_album", binaryMessenger: registrar.messenger())
    
    let galleryFactory = PlatformGalleryViewFactory()
    registrar.register(galleryFactory, withId: "platform_gallery_view")
    
    let cameraFactory = PlatformCameraViewFactory()
    
    registrar.register(cameraFactory, withId: "platform_camera_view")
    
    let instance = SwiftCameraAlbumPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let _ = delete(atPath: tmpNwdn)
    let _ = creatDir(atPath: tmpNwdn)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestImageFile":
        let params = call.arguments as! NSDictionary
        let identifier = params["identifier"] as! String
        if let image = Image.initWith(identifier: identifier) {
        image.resolveImageData { (imageData, info) in
            if let imageData = imageData, let info = info, let fileName = info["PHImageFileUTIKey"] as? String {
                var path = tmpNwdn + identifier.replacingOccurrences(of: "/", with: "") + "." + (fileName.components(separatedBy: ".").last ?? "")
                if path.components(separatedBy: ".").last == "heic" {
                    path = (path.components(separatedBy: ".").first ?? "") + ".jpeg"
                }
                
                try? FileManager.default.removeItem(atPath: path)
                try? imageData.write(to: URL(fileURLWithPath: path), options: .atomic)
                result(path)
                }
            }
        }
    case "requestVideoFile":
        let params = call.arguments as! NSDictionary
        let identifier = params["identifier"] as! String
        if let video = Video.initWith(identifier: identifier) {
            // https://blog.csdn.net/qq_22157341/article/details/80758683
            if let assetResource = PHAssetResource.assetResources(for: video.asset).first {
            let fileName = assetResource.originalFilename
                let path = tmpNwdn + fileName
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
    case "startCamera":    
        NotificationCenter.default.post(name: NSNotification.Name("startCamera"), object: self, userInfo: nil)
    case "switchCamera":
        NotificationCenter.default.post(name: NSNotification.Name("switchCamera"), object: self, userInfo: nil)
    case "takePhoto":
        NotificationCenter.default.post(name: NSNotification.Name("takePhoto"), object: self, userInfo: nil)
    case "setFlashMode":
        if let value = call.arguments as? Int {
            NotificationCenter.default.post(name: NSNotification.Name("setFlashMode"), object: self, userInfo: ["mode": (AVCaptureDevice.FlashMode(rawValue: value) ?? .off)])
        }
    case "startRecord":
        NotificationCenter.default.post(name: NSNotification.Name("startRecord"), object: self, userInfo: nil)
    case "stopRecord":
        NotificationCenter.default.post(name: NSNotification.Name("stopRecord"), object: self, userInfo: nil)
    default: break
    }
  }

     /// 判断文件是否存在
    private static func isExist(atPath filePath : String) -> Bool {
         return FileManager.default.fileExists(atPath: filePath)
     }
     
    /// 创建文件目录
    private static func creatDir(atPath dirPath : String) -> Bool {
     
         if isExist(atPath: dirPath) {
             return false
         }
     
         do {
             try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
             return true
         } catch {
             print(error)
             return false
         }
     }
    
    /// 删除文件 或者目录
    private static func delete(atPath filePath : String) -> Bool {
         guard isExist(atPath: filePath) else {
             return false
         }
         do {
             try FileManager.default.removeItem(atPath: filePath)
             return true
         } catch  {
             print(error)
             return false
         }
     }
}

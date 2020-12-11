import Flutter
import UIKit
import Photos
import MBProgressHUD

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
    let keyWindow = UIApplication.shared.keyWindow!
    switch call.method {
    case "requestImagePreview":
        MBProgressHUD.showAdded(to: keyWindow, animated: true)
        let params = call.arguments as! NSDictionary
        let identifier = params["identifier"] as! String
        if let image = Image.initWith(identifier: identifier) {
            image.resolveTargetSize(CGSize(width: 2048, height: 2048)) { (image, info) in
                if let image = image, let _ = info, let fileName = identifier.components(separatedBy: "/").first {
                                        
                    let path = tmpNwdn + fileName + ".jpeg"
                
                    try? FileManager.default.removeItem(atPath: path)
                    try? image.jpegData(compressionQuality: 1)?.write(to: URL(fileURLWithPath: path), options: .atomic)
                    result(path)
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: keyWindow, animated: true)
                    }
                }
            }
        }
    case "requestImageFile":
        MBProgressHUD.showAdded(to: keyWindow, animated: true)
        let params = call.arguments as! NSDictionary
        let identifier = params["identifier"] as! String
//        let isOrigin = params["origin"] as? Bool ?? false
        if let image = Image.initWith(identifier: identifier) {
            /// 图片像素超过4096*4096时取4096
            let limit = 4096
//            print("宽度:")
//            print(image.asset.pixelWidth)
//            print("高度:")
//            print(image.asset.pixelHeight)
            let gif = (image.asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true
            let isOrigin = image.asset.pixelWidth < limit && image.asset.pixelHeight < limit
            if gif {
                // 取原图
                image.resolveImageData { (imageData, info) in
                    if let imageData = imageData, let info = info, let fileName = info["PHImageFileUTIKey"] as? String {
                        var path = tmpNwdn + identifier.replacingOccurrences(of: "/", with: "") + "." + (fileName.components(separatedBy: ".").last ?? "")
                        if path.components(separatedBy: ".").last == "heic" {
                            path = (path.components(separatedBy: ".").first ?? "") + ".jpeg"
                        }
                        try? FileManager.default.removeItem(atPath: path)
                        try? imageData.write(to: URL(fileURLWithPath: path), options: .atomic)
                        result(path)
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: keyWindow, animated: true)
                        }
                        }
                    }
            } else {
                let size = isOrigin ? PHImageManagerMaximumSize : CGSize(width: 4096, height: 4096)
                image.resolveTargetSize(size) { (image, info) in
                    if let image = image, let _ = info, let fileName = identifier.components(separatedBy: "/").first {
                                            
                        let path = tmpNwdn + fileName + ".jpeg"
                    
                        try? FileManager.default.removeItem(atPath: path)
                        try? image.jpegData(compressionQuality: 0.5)?.write(to: URL(fileURLWithPath: path), options: .atomic)
                        result(path)
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: keyWindow, animated: true)
                        }
                    }
                }
            }
        }
    case "requestVideoFile":
        MBProgressHUD.showAdded(to: keyWindow, animated: true)
        let params = call.arguments as! NSDictionary
        let identifier = params["identifier"] as! String
        if let video = Video.initWith(identifier: identifier) {
            // https://blog.csdn.net/qq_22157341/article/details/80758683
            if let assetResource = PHAssetResource.assetResources(for: video.asset).first {
            let fileName = assetResource.originalFilename
                let path = tmpNwdn + fileName
                try? FileManager.default.removeItem(atPath: path)
            
            let options = PHAssetResourceRequestOptions()
                options.isNetworkAccessAllowed = true
            PHAssetResourceManager.default().writeData(for: assetResource, toFile: URL(fileURLWithPath: path), options: options) { (error) in
                if let error = error {
                    print(error);
                } else {
                    result(path)
                }
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: keyWindow, animated: true)
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
    case "requestLastImage":
        if let params = call.arguments as? NSDictionary {
        if let type = params["type"] as? String {
        let imagesLibrary = ImagesLibrary(mediaType: type == "video" ? .video : .image)
        imagesLibrary.reload {
            if let album = imagesLibrary.albums.first {
                if let item = album.items.first {
                    let options = PHImageRequestOptions()
                    options.isNetworkAccessAllowed = true

                      PHImageManager.default().requestImage(
                        for: item.asset,
                      targetSize: CGSize(width: 100, height: 100),
                      contentMode: .aspectFill,
                      options: options) { image, _ in
                        result(image?.jpegData(compressionQuality: 0.8))
                    }
                }
            }
        }
        }
        }
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

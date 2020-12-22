import Flutter
import UIKit
import Photos

private let kNwdnAsset = "nwdn_asset/"
let tmpNwdn = NSTemporaryDirectory() + kNwdnAsset

public class SwiftCameraAlbumPlugin: NSObject, FlutterPlugin {
    
  static var channel: FlutterMethodChannel!
    
    static var flutterEngine = FlutterEngine(name: "showPhotoLibraryEngine")
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "flutter/camera_album", binaryMessenger: registrar.messenger())
    
    let galleryFactory = PlatformGalleryViewFactory()
    registrar.register(galleryFactory, withId: "platform_gallery_view")
    
    let cameraFactory = PlatformCameraViewFactory()
    
    registrar.register(cameraFactory, withId: "platform_camera_view")
    
    let instance = SwiftCameraAlbumPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    SwiftCameraAlbumPlugin.flutterEngine.run(withEntrypoint: nil, initialRoute: "/editPage")
    
    let _ = delete(atPath: tmpNwdn)
    let _ = creatDir(atPath: tmpNwdn)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestImagePreview":
        let params = call.arguments as! NSDictionary
        let identifier = params["identifier"] as! String
        if let image = Image.initWith(identifier: identifier) {
            image.resolveTargetSize(CGSize(width: 2048, height: 2048)) { (image, info) in
                if let image = image, let _ = info, let fileName = identifier.components(separatedBy: "/").first {
                                        
                    let path = tmpNwdn + fileName + ".jpeg"
                
                    try? FileManager.default.removeItem(atPath: path)
                    try? image.jpegData(compressionQuality: 1)?.write(to: URL(fileURLWithPath: path), options: .atomic)
                    result(path)
                }
            }
        }
    case "requestImageFile":
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
            let isOrigin = image.asset.pixelWidth < limit && image.asset.pixelHeight < limit
            if isOrigin {
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
                        }
                    }
            } else {
                image.resolveTargetSize(CGSize(width: 4096, height: 4096)) { (image, info) in
                    if let image = image, let _ = info, let fileName = identifier.components(separatedBy: "/").first {
                                            
                        let path = tmpNwdn + fileName + ".jpeg"
                    
                        try? FileManager.default.removeItem(atPath: path)
                        try? image.jpegData(compressionQuality: 0.9)?.write(to: URL(fileURLWithPath: path), options: .atomic)
                        result(path)
                    }
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
    case "showPhotoLibrary":
        /*
         enum MediaType {
           unknown, // 0
           image, // 1
           video, // 2
           audio, // 3
         }
         */
        let params = call.arguments as! NSDictionary
        let maxSelectCount = params["maxSelectCount"] as! Int
        let mediaType = PHAssetMediaType(rawValue: (params["mediaType"] as! Int))
        let taskTitle = (params["taskTitle"] as? String) ?? ""
        let takeTitle = (params["takeTitle"] as? String) ?? ""
        let data = params["data"]
        
        let controller = UIApplication.shared.keyWindow?.rootViewController

        if let sender = controller {
            
            let deploy = ZLPhotoThemeColorDeploy.default()
            deploy.thumbnailBgColor = UIColor.white
            deploy.albumListBgColor = UIColor.white
            deploy.albumListTitleColor = UIColor.black
            deploy.separatorColor = UIColor.clear
            
            let config = ZLPhotoConfiguration.default()
            config.navTaskTitle = taskTitle
            config.bottomTakeTitle = takeTitle
            config.style = .dagongAlbumList
            config.statusBarStyle = .default
            config.themeColorDeploy = deploy
            config.allowEditImage = false
            config.allowTakePhotoInLibrary = false
            config.maxSelectCount = maxSelectCount
            config.showSelectBtnWhenSingleSelect = false
            config.allowSelectOriginal = false
            config.allowPreviewPhotos = false
            config.showSelectedPhotoPreview = false
            config.showPreviewButtonInAlbum = false
            config.allowMixSelect = false
            config.sortAscending = false
            config.maxSelectVideoDuration = 60*60*24
            ZLPhotoConfiguration.default().timeout = 120
            if maxSelectCount == 1 {
                config.showSelectedIndex = false
                config.allowSlideSelect = false
            } else {
                config.showSelectedIndex = true
                config.allowSlideSelect = true
            }
            switch mediaType {
            case .image:
                config.allowSelectVideo = false
                config.allowSelectImage = true
            case .video:
                config.allowSelectVideo = true
                config.allowSelectImage = false
            default:
                break
            }
            let ac = ZLPhotoPreviewSheet()
            ac.selectImageBlock = { (images, assets, isOriginal, originPaths, previewPaths, durations) in
                debugPrint("\(images)  -  \(assets) - \(isOriginal)")
                
                switch mediaType {
                case .image:
                    SwiftCameraAlbumPlugin.channel.invokeMethod("onSelectedHandler", arguments: ["paths": originPaths, "previewPaths": previewPaths])
                case .video:
                    SwiftCameraAlbumPlugin.channel.invokeMethod("onSelectedHandler", arguments: ["paths": originPaths, "durations": durations])
                default:
                    break
                }
                if ZLPhotoConfiguration.default().maxSelectCount > 1 {
                    ac.sender?.dismiss(animated: true, completion: nil)
                } else {
                    let flutterViewController =
                        FlutterViewController(engine: SwiftCameraAlbumPlugin.flutterEngine, nibName: nil, bundle: nil)
                    ac.nav?.pushViewController(flutterViewController, animated: true)
//                    ThrioNavigator.pushUrl("/edit_page", params: 1) { (ok) in
//                        print(ok)
//                    }
                    let channel = FlutterMethodChannel(name: "edit_page_channel", binaryMessenger: flutterViewController as! FlutterBinaryMessenger)
                    channel.invokeMethod("selected", arguments: ["data": data, "mediaType": mediaType?.rawValue ?? 0, "paths": originPaths, "previewPaths": previewPaths, "durations": durations])
                    channel.setMethodCallHandler { (call, result) in
                        if call.method == "pop" {
                            flutterViewController.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        
            ac.cancelBlock = {
                debugPrint("cancel select")
            }
            ac.selectImageRequestErrorBlock = { (errorAssets, errorIndexs) in
                debugPrint("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
            }
            ac.showPhotoLibrary(sender: sender)
        } else {
            result([])
        }
    case "pop":
        let controller = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController
        controller?.dismiss(animated: true, completion: {
            
        })
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

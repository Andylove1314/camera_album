import UIKit
import Photos
import Flutter
import thrio

private let kNwdnAsset = "nwdn_asset/"
let tmpNwdn = NSTemporaryDirectory() + kNwdnAsset

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    ThrioModule.`init`(MainModule())
    
    let nvc = NavigatorNavigationController.init(url: "/", params: nil)
    self.window.rootViewController = nvc
    self.window.makeKeyAndVisible()
    
    let nwdnChannel = FlutterMethodChannel(name: "com.bigwinepot/nwdn", binaryMessenger: ThrioNavigator.getEngineByEntrypoint("main").binaryMessenger);
    nwdnChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        self?.setMethodCallHandler(call: call, result: result)
    });

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func setMethodCallHandler(call: FlutterMethodCall, result: FlutterResult) {
        if ("showPhotoLibrary" == call.method) {
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
                    
//                    if ZLPhotoConfiguration.default().maxSelectCount > 1 {
//                        ac.sender?.dismiss(animated: true, completion: nil)
//                    }
                    ThrioNavigator.pushUrl("/image_edit", params: ["data": data, "mediaType": mediaType?.rawValue ?? 0, "paths": originPaths, "previewPaths": previewPaths, "durations": durations]) { (ok) in
                        print("image_edit_poppedResult:\(ok)")
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
        }
    }
}

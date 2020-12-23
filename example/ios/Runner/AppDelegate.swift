import UIKit
import Photos
import Flutter
import thrio

private let kNwdnAsset = "nwdn_asset/"
let tmpNwdn = NSTemporaryDirectory() + kNwdnAsset

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private var arrSelectedModels: [ZLPhotoModel] = []
    
    private var fetchImageQueue: OperationQueue = OperationQueue()
    
    @objc public var selectImageBlock: ( ([UIImage], [PHAsset], Bool, [String], [String], [Double]) -> Void )?
    
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
    
    func showPhotoLibrary(sender: UIViewController) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .restricted || status == .denied {
            showAlertView(String(format: localLanguageTextValue(.noPhotoLibratyAuthority), getAppName()), sender)
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    if status == .denied {
                        showAlertView(String(format: localLanguageTextValue(.noPhotoLibratyAuthority), getAppName()), sender)
                    } else if status == .authorized {
                        self.showThumbnailViewController(sender: sender)
                    }
                }
            }
            
            
        } else {
            self.showThumbnailViewController(sender: sender)
        }
    }
    
    func showThumbnailViewController(sender: UIViewController) {
        ZLPhotoManager.getCameraRollAlbum(allowSelectImage: ZLPhotoConfiguration.default().allowSelectImage, allowSelectVideo: ZLPhotoConfiguration.default().allowSelectVideo) { [weak self] (cameraRoll) in
            guard let `self` = self else { return }
            let nav: ZLImageNavController
            let tvc = ZLThumbnailViewController(albumList: cameraRoll)
            nav = self.getImageNav(rootViewController: tvc)
            sender.showDetailViewController(nav, sender: nil)
        }
    }
    
    func getImageNav(rootViewController: UIViewController) -> ZLImageNavController {
        let nav = ZLImageNavController(rootViewController: rootViewController)
        nav.modalPresentationStyle = .fullScreen
        nav.selectImageBlock = { [weak self, weak nav] in
//            self?.isSelectOriginal = nav?.isSelectedOriginal ?? false
            self?.arrSelectedModels.removeAll()
            self?.arrSelectedModels.append(contentsOf: nav?.arrSelectedModels ?? [])
            self?.requestSelectPhoto(viewController: nav)
        }
        
        nav.cancelBlock = { [weak self] in
//            self?.cancelBlock?()
//            self?.hide()
        }
//        nav.isSelectedOriginal = self.isSelectOriginal
        nav.arrSelectedModels.removeAll()
        nav.arrSelectedModels.append(contentsOf: self.arrSelectedModels)
        
        return nav
    }
    
    func requestSelectPhoto(viewController: UIViewController? = nil) {
        guard !self.arrSelectedModels.isEmpty else {
            // + TODO:修改源码
            self.selectImageBlock?([], [], false, [], [], [])
            // + TODO:修改源码
//            self.hide()
            viewController?.dismiss(animated: true, completion: nil)
            return
        }
        
        let config = ZLPhotoConfiguration.default()
        
        if config.allowMixSelect {
            let videoCount = self.arrSelectedModels.filter { $0.type == .video }.count
            
            if videoCount > config.maxVideoSelectCount {
                showAlertView(String(format: localLanguageTextValue(.exceededMaxVideoSelectCount), ZLPhotoConfiguration.default().maxVideoSelectCount), viewController)
                return
            } else if videoCount < config.minVideoSelectCount {
                showAlertView(String(format: localLanguageTextValue(.lessThanMinVideoSelectCount), ZLPhotoConfiguration.default().minVideoSelectCount), viewController)
                return
            }
        }
        
        let hud = ZLProgressHUD(style: ZLPhotoConfiguration.default().hudStyle)
        
        var timeout = false
        hud.timeoutBlock = { [weak self] in
            timeout = true
            showAlertView(localLanguageTextValue(.timeout), viewController)
            self?.fetchImageQueue.cancelAllOperations()
        }
        
        hud.show(timeout: ZLPhotoConfiguration.default().timeout)
        
        guard ZLPhotoConfiguration.default().shouldAnialysisAsset else {
            hud.hide()
            // + TODO:修改源码
            self.selectImageBlock?([], self.arrSelectedModels.map { $0.asset }, false, [], [], [])
            // + TODO:修改源码
            self.arrSelectedModels.removeAll()
//            self.hide()
            viewController?.dismiss(animated: true, completion: nil)
            return
        }
        
        var images: [UIImage?] = Array(repeating: nil, count: self.arrSelectedModels.count)
        var assets: [PHAsset?] = Array(repeating: nil, count: self.arrSelectedModels.count)
        // + TODO:修改源码
        var originPaths: [String?] = Array(repeating: nil, count: self.arrSelectedModels.count)
        var previewPaths: [String?] = Array(repeating: nil, count: self.arrSelectedModels.count)
        var durations: [Double?] = Array(repeating: nil, count: self.arrSelectedModels.count)
        // + TODO:修改源码
        var errorAssets: [PHAsset] = []
        var errorIndexs: [Int] = []
        
        var sucCount = 0
        let totalCount = self.arrSelectedModels.count
        for (i, m) in self.arrSelectedModels.enumerated() {
            let operation = ZLFetchImageOperation(model: m, isOriginal: false) {
                // + TODO:修改源码
                [weak self] (image, asset, originPath, previewPath, duration) in
                // + TODO:修改源码
                guard !timeout else { return }
                
                sucCount += 1
                
                if let image = image {
                    images[i] = image
                    assets[i] = asset ?? m.asset
                    // + TODO:修改源码
                    originPaths[i] = originPath
                    previewPaths[i] = previewPath
                    durations[i] = duration
                    // + TODO:修改源码
                    zl_debugPrint("ZLPhotoBrowser: suc request \(i)")
                } else {
                    errorAssets.append(m.asset)
                    errorIndexs.append(i)
                    zl_debugPrint("ZLPhotoBrowser: failed request \(i)")
                }
                
                guard sucCount >= totalCount else { return }
                let sucImages = images.compactMap { $0 }
                let sucAssets = assets.compactMap { $0 }
                // + TODO:修改源码
                let sucOriginPaths = originPaths.compactMap { $0 }
                let sucPreviewPaths = previewPaths.compactMap { $0 }
                let sucDurations = durations.compactMap { $0 }
                // + TODO:修改源码
                hud.hide()
                
                // + TODO:修改源码
                self?.selectImageBlock?(sucImages, sucAssets, false, sucOriginPaths, sucPreviewPaths, sucDurations)
                // + TODO:修改源码
                self?.arrSelectedModels.removeAll()
//                if !errorAssets.isEmpty {
//                    self?.selectImageRequestErrorBlock?(errorAssets, errorIndexs)
                }
//                self?.arrDataSources.removeAll()
//                self?.hide()
                // + TODO:修改源码
//                viewController?.dismiss(animated: true, completion: nil)
                // + TODO:修改源码
            self.fetchImageQueue.addOperation(operation)
            }
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
                showPhotoLibrary(sender: sender)
//                let ac = ZLPhotoPreviewSheet()
                self.selectImageBlock = { (images, assets, isOriginal, originPaths, previewPaths, durations) in
                    debugPrint("\(images)  -  \(assets) - \(isOriginal)")

//                    if ZLPhotoConfiguration.default().maxSelectCount > 1 {
//                        ac.sender?.dismiss(animated: true, completion: nil)
//                    }
                    ThrioNavigator.pushUrl("/image_edit", params: ["data": data, "mediaType": mediaType?.rawValue ?? 0, "paths": originPaths, "previewPaths": previewPaths, "durations": durations]) { (ok) in
                        print("image_edit_poppedResult:\(ok)")
                    }
                }
//
//                ac.cancelBlock = {
//                    debugPrint("cancel select")
//                }
//                ac.selectImageRequestErrorBlock = { (errorAssets, errorIndexs) in
//                    debugPrint("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
//                }
//                ac.showPhotoLibrary(sender: sender)
            } else {
                result([])
            }
        }
    }
}

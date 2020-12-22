import UIKit
import Flutter
import thrio

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
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

import UIKit
import Flutter
import GoogleMobileAds

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    //add this line for iOS Admob integration
    GADMobileAds.sharedInstance().start(completionHandler: nil)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// Application's delegate

import UIKit
import ARKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    open var modelUrl : URL?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Use Firebase library to configure APIs
         
        
        Constants.w = UIScreen.main.bounds.width
        Constants.h = UIScreen.main.bounds.height
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """)
        }
        
        /*if let viewController = self.window?.rootViewController as? ViewController {
            
            // add map as a child
            
            let mapViewController = MAPViewController()
            let mapInteractor = MAPInteractor()
            let mapPresenter = MAPPresenter(view: mapViewController, interactor: mapInteractor)
            mapViewController.presenter = mapPresenter
            
            viewController.view.addSubview(mapViewController.view)
            viewController.addChild(mapViewController)
        }*/
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        /*if let viewController = self.window?.rootViewController as? ViewController {
            viewController.blurView.isHidden = false
        }*/
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // If the app supports background execution, this method is called instead of applicationWillTerminate: when the user quits
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        /*if let viewController = self.window?.rootViewController as? ViewController {
            viewController.blurView.isHidden = true
        }*/
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the app is about to terminate
    }
}

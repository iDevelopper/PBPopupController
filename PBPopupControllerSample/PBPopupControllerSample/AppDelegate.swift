//
//  AppDelegate.swift
//  PBPopupControllerSample
//
//  Created by Patrick BODET on 18/04/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import PBPopupController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var rootViewController: UIViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
            self.window?.tintColor = UIColor.systemPink
        } else {
            self.window?.tintColor = UIColor.red
        }
        let font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        PBPopupLogs.instance.isEnabled = true // default, false will disable logging from the module PBPopupController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

@available(iOS 13.0, *)
extension AppDelegate {
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "PBPopupControllerSample", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate {
    func replaceRootViewControllerWith(controller: UIViewController) {
        var rootVC:UIViewController? = nil
        if #available(iOS 13.0, *) {
            for window in UIApplication.shared.windows {
                if window.isKeyWindow {
                    rootVC = window.rootViewController
                    window.rootViewController = controller
                }
            }
        } else {
            rootVC = self.window?.rootViewController
            self.window?.rootViewController = controller
        }
        if let nc = rootVC as? UINavigationController, let _ = nc.topViewController as? MainTableViewController {
            self.rootViewController = rootVC
        }
    }
    
    func getRootViewController() -> UIViewController! {
        var rootVC:UIViewController? = nil
        if #available(iOS 13.0, *) {
            for window in UIApplication.shared.windows {
                if window.isKeyWindow {
                    rootVC = window.rootViewController
                }
            }
        } else {
            rootVC = self.window?.rootViewController
        }
        return rootVC
    }
    
    func restoreInitialRootViewControllerIfNeeded() {
        guard let rootViewController = self.rootViewController else {
            return
        }
        if let rootVC = self.getRootViewController(), rootVC != rootViewController {
            self.replaceRootViewControllerWith(controller: rootViewController)
        }
    }
}

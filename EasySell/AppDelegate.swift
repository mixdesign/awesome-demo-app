//
//  AppDelegate.swift
//  EasySell
//
//  Created by Almas Adilbek on 12/1/17.
//  Copyright © 2017 Good App. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        configAppearanceAndSettings()

        // Realm
        RealmHelper.setup()

        self.window = UIWindow()
//        self.window?.rootViewController = DesignPostController()
        let nc = UINavigationController(rootViewController: PostsController())
        nc.isNavigationBarHidden = true
        self.window?.rootViewController = nc
        self.window?.frame = UIScreen.main.bounds
        self.window?.makeKeyAndVisible()

        return true
    }
}

// MARK: UI

extension AppDelegate {

    func configAppearanceAndSettings() {

        // Keyboard
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemText = "↓"
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
    }

}


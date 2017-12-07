//
// Created by Almas Adilbek on 8/4/17.
// Copyright (c) 2017 GOOD/APP. All rights reserved.
//

import UIKit

class UIHelper {

    // MARK: Alert

    class func alertError(message:String?) {
        alert(title: "Error", message: message)
    }

    static func alert(title:String?, message:String?, actionButtons:[String] = ["OK"], cancelButton:String? = nil, handler:((UIAlertAction) -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)

        for button in actionButtons {
            alert.addAction(UIAlertAction(title: button, style: cancelButton == nil && actionButtons.count == 1 ? .cancel : .default, handler: handler))
        }

        if let button = cancelButton {
            alert.addAction(UIAlertAction(title: button, style: .cancel, handler: handler))
        }

        getVisibleViewController(UIApplication.shared.keyWindow?.rootViewController)?.present(alert, animated: true)
    }

    // MARK: Helper

    static func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {

        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }

        if rootVC?.presentedViewController == nil {
            return rootVC
        }

        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }

            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }

            return getVisibleViewController(presented)
        }
        return nil
    }

}

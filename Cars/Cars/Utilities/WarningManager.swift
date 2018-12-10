//
//  WarningManager.swift
//  Movie
//
//  Created by Sasi M on 27/07/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

// Simple wrapper class to create and push alerts
// Supports tuples / completion blocks to handle user interaction

import UIKit

class WarningManager: NSObject {
    
    class func createAndPushWarning(message: String, cancel: String) {
        let alertControl = WarningManager.createAlertControl(message: message)
        alertControl.addAction(UIAlertAction(title: cancel, style: .default, handler: nil))
        self.displayAlertControl(alert: alertControl)
    }
    
    class func createAndPushWarning(message: String, buttons : [(title: String, callBack:(() -> Void)?)]?) {  // cancel button has to be sent in tuple
        let alertControl = WarningManager.createAlertControl(message: message)
        if (buttons != nil) {
            for item in buttons! {
                alertControl.addAction(UIAlertAction(title: item.title, style: .default, handler: { (action) in
                    if (item.callBack != nil) {
                        item.callBack!()
                    }
                }))
            }
        }
        self.displayAlertControl(alert: alertControl)
    }
    
    //Mark: Private Methods
    
    private class func createAlertControl(message: String) -> UIAlertController {
        return UIAlertController.init(title: NSLocalizedString("Cars", comment: ""), message: message, preferredStyle: .alert)
    }
    
    private class func displayAlertControl(alert: UIAlertController) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
}



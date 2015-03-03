//
//  ViewControllerExtensions.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 3/1/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func presentIndeterminiteMessage(message:String) -> MBProgressHUD {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = message
        hud.dimBackground = false
        return hud
    }
    
    func presentErrorMessage(error:NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
    }
    
}

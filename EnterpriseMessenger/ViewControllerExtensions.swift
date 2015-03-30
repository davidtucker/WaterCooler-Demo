//
//  ViewControllerExtensions.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 3/1/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

extension UIViewController {
    
    /*
        The following method leverages MBProgressHUD to present an indeterminite
        message to the user.  The instance of MBProgressHUD is returned (which is
        required so that it can be closed when needed).
    */
    func presentIndeterminiteMessage(message:String) -> MBProgressHUD {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = message
        hud.dimBackground = false
        return hud
    }
    
    /*
        The following method leverages UIAlertController to present a message to the
        end user based on an NSError instance.  This is a bit of a shortcut as we would
        usually like to put a lot more thought into how / when error messages are
        presented to the end user.  However, for a demo application this is adequate.
        The message that is presented is the localizedDescription of the error.
    */
    func presentErrorMessage(error:NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
    }
    
}

//
//  ChangePasswordViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 3/1/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

class ChangePasswordViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        saveButton.enabled = false
        passwordField.becomeFirstResponder()
    }
    
    @IBAction func passwordFieldChanged(sender:AnyObject) {
        saveButton.enabled = arePasswordFieldsValid()
    }
    
    @IBAction func saveNewPassword(sender:AnyObject) {
        let hud = presentIndeterminiteMessage("Updating Password")
        KCSUser.activeUser().changePassword(passwordField.text, completionBlock: { (results, error) -> Void in
            hud.hide(true)
            if(error != nil) {
                self.presentErrorMessage(error)
            } else {
                self.view.endEditing(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    @IBAction func cancelChangePassword(sender:AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == passwordField) {
            confirmField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    private func arePasswordFieldsValid() -> Bool {
        if(passwordField.text?.characters.count < 1 || confirmField.text?.characters.count < 1) {
            return false
        }
        
        if(passwordField.text != confirmField.text) {
            return false
        }
        
        return true
    }
    
}
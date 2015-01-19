//
//  LandingPageViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/20/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

@objc(LandingPageViewController)

class LandingPageViewController : UIViewController {
    
    //MARK: -
    //MARK: Private State Variables
    
    private var isShowingLoginState:Bool = false
    
    //MARK: -
    //MARK: IBOutlets
    
    @IBOutlet weak var logoImage:UIImageView?
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: BottomButton!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonContainerTopConstraint: NSLayoutConstraint!
    
    //MARK: -
    //MARK: Initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    //MARK: -
    //MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        self.view.backgroundColor = InterfaceConfiguration.keyColor;
        signupButton.hidden = true
        loginButton.hidden = true
        logoTopConstraint.constant = (view.frame.size.height / 2) - (84/2) - 20.0
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.logoTopConstraint.constant = 30.0
        self.view.setNeedsUpdateConstraints()
        self.signupButton.hidden = false
        self.loginButton.hidden = false
        self.signupButton.alpha = 0.0
        self.loginButton.alpha = 0.0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (complete) -> Void in
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.signupButton.alpha = 1.0
                self.loginButton.alpha = 1.0
            })
        }
    }
    
    //MARK: -
    //MARK: IBActions
    
    @IBAction func primaryButtonPress() {
        if(isShowingLoginState) {
            attemptLogin()
        } else {
            performSegueWithIdentifier(WaterCoolerConstants.Segue.Signup, sender: self)
        }
    }
    
    @IBAction func secondaryButtonPress() {
        if(isShowingLoginState) {
            cancelLoginState()
        } else {
            showLoginState()
        }
    }
    
    //MARK: -
    //MARK: Private Methods
    
    private func showLoginState() {
        clearLoginFields()
        buttonContainerTopConstraint.constant = 130.0
        view.setNeedsUpdateConstraints()
        loginView.hidden = false
        loginView.alpha = 0.0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.signupButton.setTitle("Login", forState: UIControlState.Normal)
            self.loginButton.setTitle("Cancel", forState: UIControlState.Normal)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.loginView.alpha = 1.0
                    }) { (completed) -> Void in
                        self.isShowingLoginState = true
                        self.loginEmailField.becomeFirstResponder()
                }
        }
    }
    
    private func cancelLoginState() {
        buttonContainerTopConstraint.constant = 24.0
        view.setNeedsUpdateConstraints()
        loginEmailField.resignFirstResponder()
        loginPasswordField.resignFirstResponder()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.signupButton.setTitle("Sign Up", forState: UIControlState.Normal)
            self.loginButton.setTitle("Login", forState: UIControlState.Normal)
            self.loginView.alpha = 0.0
            }) { (finished) -> Void in
                self.loginView.hidden = true
                self.isShowingLoginState = false
        }
    }
    
    private func clearLoginFields() {
        loginPasswordField.text = ""
        loginEmailField.text = ""
    }
    
    //MARK: -
    //MARK: Login Handling
    
    func attemptLogin() {
        let username = loginEmailField.text
        let password = loginPasswordField.text
        KCSUser.loginWithUsername(username, password: password) { (user, error, actionResult) -> Void in
            if(error == nil) {
                self.successfulLogin()
            } else {
                self.incorrectLoginWithError(error)
            }
        }
    }
    
    func incorrectLoginWithError(error:NSError) {
        clearLoginFields()
        loginEmailField.becomeFirstResponder()
        let alert = UIAlertController(title: "Failed Login", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion:nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func successfulLogin() {
        performSegueWithIdentifier(WaterCoolerConstants.Segue.Login, sender: self)
    }
    
}

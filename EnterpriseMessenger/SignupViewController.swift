//
//  SignupViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/20/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController : UserDetailBaseViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func profileMode() -> ProfileMode {
        return .Signup
    }
    
    @IBAction func cancelSignup(sender:AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled = false
    }
    
    //MARK: --
    //MARK: ProfileViewDelegate Implementation
    
    func profileDidChangeCompletionStatus(isComplete: Bool) {
        saveButton.enabled = isComplete
    }

}
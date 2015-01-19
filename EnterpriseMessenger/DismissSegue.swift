//
//  DismissSegue.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/9/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

@objc(DismissSegue)

class DismissSegue : UIStoryboardSegue {
    
    override func perform() {
        self.sourceViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
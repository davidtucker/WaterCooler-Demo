//
//  TextField.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/19/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class TextField : UITextField {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.backgroundColor = UIColor.clearColor();
        self.borderStyle = UITextBorderStyle.None;
    }
    
}
//
//  BottomButton.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/19/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class BottomButton : UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.layer.borderColor = UIColor.whiteColor().CGColor;
    }
    
}
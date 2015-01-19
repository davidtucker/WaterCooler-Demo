//
//  AboutTextView.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/17/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

class AboutTextView : UITextView {
    
    override func intrinsicContentSize() -> CGSize {
        let content = attributedText
        let rect = content.boundingRectWithSize(CGSizeMake(frame.size.width, CGFloat.max), options: ObjCUtil.standardStringDrawingOptions(), context: nil)
        return rect.size
    }
    
}
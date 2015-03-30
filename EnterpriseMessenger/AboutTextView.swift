//
//  AboutTextView.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/17/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

/*
    This method was utilized to create a variable height dynamic UITextView for
    use inside of a UIScrollView leveraging auto-layout. This allows the
    intrinsicContentSize to be factored in for the content that is being
    shown.
*/
class AboutTextView : UITextView {
    
    override func intrinsicContentSize() -> CGSize {
        let content = attributedText
        let rect = content.boundingRectWithSize(CGSizeMake(frame.size.width, CGFloat.max), options: ObjCUtil.standardStringDrawingOptions(), context: nil)
        return rect.size
    }
    
}
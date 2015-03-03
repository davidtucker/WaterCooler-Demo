//
//  MessageTableViewCellBase.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/25/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class MessageTableViewCellBase : UITableViewCell {
    
    internal var margin:CGFloat = 5.0
    internal var caretTopOffset:CGFloat = 6.0
    internal var borderRadius:CGFloat = 10.0
    internal var profilePicSize:CGSize = CGSizeMake(30.0, 30.0)
    internal var caretSize:CGSize = CGSizeMake(6.0, 12.0)
    
    var bubbleColor:UIColor = UIColor.lightGrayColor()
    
    var messageContent:String = "" {
        didSet {
            messageText.text = messageContent
        }
    }
    
    lazy var messageText:UILabel = {
        let messageText = UILabel()
        messageText.setTranslatesAutoresizingMaskIntoConstraints(false)
        messageText.textColor = UIColor.darkGrayColor()
        messageText.backgroundColor = UIColor.clearColor()
        messageText.numberOfLines = 0
        messageText.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        return messageText
    }()
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        // Clear the Current Bounds
        UIColor.whiteColor().set()
        CGContextClearRect(context, self.bounds)
        CGContextFillRect(context, rect)
        CGContextSetLineJoin(context, kCGLineJoinRound)
        CGContextSetFillColorWithColor(context, bubbleColor.CGColor)
        
        // Draw and Fill the Path
        CGContextBeginPath(context);
        drawBubblePath(context);
        CGContextClosePath(context)
        CGContextFillPath(context)
    }
    
    func drawBubblePath(context:CGContextRef) {
        assert(false, "Implement in Subclass")
    }
    
}
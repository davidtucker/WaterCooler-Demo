//
//  MessageTableViewCellBase.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/25/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

/*
    This is a base classes that contains the core logic for the message cell.  This
    is designed to be subclassed to provide differences between the sender and
    recipient bubble.
*/
class MessageTableViewCellBase : UITableViewCell {
    
    //MARK: - Internal Layout Metrics
    
    internal var margin:CGFloat = 5.0
    internal var caretTopOffset:CGFloat = 6.0
    internal var borderRadius:CGFloat = 10.0
    internal var profilePicSize:CGSize = CGSizeMake(30.0, 30.0)
    internal var caretSize:CGSize = CGSizeMake(6.0, 12.0)
    
    //MARK: - Instance Variables
    
    /*
        This property will be modified in subclasses to have a different color
        between the sender and recipient bubbles.
    */
    var bubbleColor:UIColor = UIColor.lightGrayColor()
    
    //MARK: - Properties
    
    var messageContent:String = "" {
        didSet {
            messageText.text = messageContent
        }
    }
    
    lazy var messageText:UILabel = {
        let messageText = UILabel()
        messageText.translatesAutoresizingMaskIntoConstraints = false
        messageText.textColor = UIColor.darkGrayColor()
        messageText.backgroundColor = UIColor.clearColor()
        messageText.numberOfLines = 0
        messageText.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        return messageText
    }()
    
    //MARK: - Drawing
    
    /*
        In this standard method we handle the setup of the custom drawing and the
        closing of it.  In the middle we call the drawBubblePath method which
        should handle the specific drawing (which will be different for sender
        and recipient bubbles in the subclasses).
    */
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        // Clear the Current Bounds
        UIColor.whiteColor().set()
        CGContextClearRect(context, self.bounds)
        CGContextFillRect(context, rect)
        CGContextSetLineJoin(context, CGLineJoin.Round)
        CGContextSetFillColorWithColor(context, bubbleColor.CGColor)
        
        // Draw and Fill the Path
        CGContextBeginPath(context);
        drawBubblePath(context);
        CGContextClosePath(context)
        CGContextFillPath(context)
    }
    
    /*
        This method should be implemented in the subclasses to handle the drawing
        specific to the type of cell.
    */
    func drawBubblePath(context:CGContextRef!) {
        assert(false, "Implement in Subclass")
    }
    
}
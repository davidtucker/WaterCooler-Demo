//
//  MessageTableViewSenderCell.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/25/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

/*
    This class is the cell for the times the user sends a message.
*/
class MessageTableViewSenderCell : MessageTableViewCellBase {
    
    //MARK: - Init & Creation
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubbleColor = InterfaceConfiguration.senderBubbleColor
        setupSubviews()
    }
    
    /*
        This method adds the subviews and sets up the auto-layot constraints.
    */
    func setupSubviews() {
        contentView.addSubview(messageText)
        
        let views = [
            "textView" : messageText
        ]
        
        let metrics = [
            "topMargin" : 15.0,
            "leftMargin" : 30.0,
            "rightMargin" : 20.0,
            "bottomMargin" : 20.0
        ]
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(topMargin)-[textView]-(bottomMargin)-|", options: nil, metrics: metrics, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(leftMargin)-[textView]-(rightMargin)-|", options: nil, metrics: metrics, views: views)
        
        contentView.addConstraints(verticalConstraints)
        contentView.addConstraints(horizontalConstraints)
    }
    
    //MARK: - Drawing
    
    /*
        This method draws the speech bubble for the sender cell.
    */
    override func drawBubblePath(context:CGContextRef) {
        let currentFrame = bounds
        let topY = margin
        let bottomY = currentFrame.size.height - (2 * margin)
        let leftX = margin * 4
        let rightX = currentFrame.size.width - (1 * margin) - caretSize.width
        
        CGContextMoveToPoint(context, leftX, topY)
        CGContextAddLineToPoint(context, rightX, topY)
        CGContextAddLineToPoint(context, rightX, topY + caretTopOffset)
        CGContextAddLineToPoint(context, rightX + caretSize.width, topY + caretTopOffset + (caretSize.height / 2))
        CGContextAddLineToPoint(context, rightX, topY + caretTopOffset + caretSize.height)
        CGContextAddLineToPoint(context, rightX, bottomY)
        CGContextAddLineToPoint(context, leftX, bottomY)
        CGContextAddLineToPoint(context, leftX, topY)
    }
    
    
    
}
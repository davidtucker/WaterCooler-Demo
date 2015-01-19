//
//  MessageTableViewCell.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/24/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

enum MessageType {
    case Sender
    case Recipient
}

class MessageTableViewRecipientCell : MessageTableViewCellBase {
    
    lazy var profilePicView:MaskedImageView = {
        let profilePicView = MaskedImageView()
        profilePicView.backgroundColor = UIColor.lightGrayColor()
        profilePicView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return profilePicView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubbleColor = InterfaceConfiguration.recipientBubbleColor
        setupSubviews()
    }
    override func drawBubblePath(context: CGContextRef) {
        let currentFrame = bounds
        let topY = margin
        let bottomY = currentFrame.size.height - (2 * margin)
        let leftX = (margin * 3) + profilePicSize.width + caretSize.width
        let rightX = currentFrame.size.width - (margin * 3)
        
        CGContextMoveToPoint(context, leftX, topY)
        CGContextAddLineToPoint(context, rightX, topY)
        CGContextAddLineToPoint(context, rightX, bottomY)
        CGContextAddLineToPoint(context, leftX, bottomY)
        CGContextAddLineToPoint(context, leftX, topY + caretTopOffset + caretSize.height)
        CGContextAddLineToPoint(context, leftX - caretSize.width, topY + caretTopOffset + (caretSize.height / 2))
        CGContextAddLineToPoint(context, leftX, topY + caretTopOffset)
        CGContextAddLineToPoint(context, leftX, topY)
    }
    
    func setupSubviews() {
        contentView.addSubview(messageText)
        contentView.addSubview(profilePicView)
        
        let views = [
            "textView" : messageText,
            "profilePic" : profilePicView
        ]
        
        let metrics = [
            "topMargin" : 15.0,
            "leftMargin" : 10.0,
            "rightMargin" : 20.0,
            "bottomMargin" : 20.0,
            "profilePicWidth" : profilePicSize.width
        ]
        
        let picVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(2)-[profilePic(==profilePicWidth)]", options: nil, metrics: metrics, views: views)
        let textVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(topMargin)-[textView]-(bottomMargin)-|", options: nil, metrics: metrics, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(leftMargin)-[profilePic(==profilePicWidth)]-(30)-[textView]-(rightMargin)-|", options: nil, metrics: metrics, views: views)
        
        contentView.addConstraints(picVerticalConstraints)
        contentView.addConstraints(textVerticalConstraints)
        contentView.addConstraints(horizontalConstraints)
    }

}

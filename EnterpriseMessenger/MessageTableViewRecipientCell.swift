//
//  MessageTableViewCell.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/24/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

/*
    This class is the cell for the times the user receives a message (is
    the recipient).
*/
class MessageTableViewRecipientCell : MessageTableViewCellBase {
    
    //MARK: - UIView Components
    
    /*
        This view has a small image of the sender within the cell (showing the
        profile pic).  This is the MaskedImageView instances used for that
        view.
    */
    lazy var profilePicView:MaskedImageView = {
        let profilePicView = MaskedImageView()
        profilePicView.backgroundColor = UIColor.lightGrayColor()
        profilePicView.translatesAutoresizingMaskIntoConstraints = false
        return profilePicView
    }()
    
    //MARK: - Initialization & Creation
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubbleColor = InterfaceConfiguration.recipientBubbleColor
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
        This view adds the subviews and sets up the auto-layout constraints.
    */
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
        
        let picVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(2)-[profilePic(==profilePicWidth)]", options: [], metrics: metrics, views: views)
        let textVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(topMargin)-[textView]-(bottomMargin)-|", options: [], metrics: metrics, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(leftMargin)-[profilePic(==profilePicWidth)]-(30)-[textView]-(rightMargin)-|", options: [], metrics: metrics, views: views)
        
        contentView.addConstraints(picVerticalConstraints)
        contentView.addConstraints(textVerticalConstraints)
        contentView.addConstraints(horizontalConstraints)
    }
    
    //MARK: - Properties
    
    /*
        This property is the user (which sent the message).  When set, this value
        will populate the profile picture.
    */
    var user:KCSUser? = nil {
        didSet {
            if let profileImage = user?.getProfileImage() {
                profilePicView.image = profileImage
            } else {
                user?.populateProfileImage { (image) -> () in
                    self.profilePicView.image = image
                }
            }

        }
    }
    
    //MARK: - Drawing
    
    /*
        This method draws the speech bubble for the recipient cell.
    */
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

}

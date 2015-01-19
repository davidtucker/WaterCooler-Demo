//
//  MessageTableViewCell.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/21/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class MessageThreadTableViewCell : UITableViewCell {
    
    class var viewMetrics:[NSString:CGFloat] {
        return [
            "outerGap" : 8.0,
            "timeGap" : 10.0,
            "picSize" : 50.0,
            "minRecipientWidth" : 106.0,
            "minTimeWidth" : 75.0,
            "accessoryAllowance" : 38.0
        ]
    }
    
    class func heightForMessageText(messageText:String, width:CGFloat) -> CGFloat {
        
        let font = InterfaceConfiguration.contentFont
        
        let attributes = [
            NSFontAttributeName: font
        ]
        
        let messageString:NSString = NSString(string: messageText)
        let horizontalSpacing = (2 * viewMetrics["outerGap"]!) + viewMetrics["picSize"]! + viewMetrics["timeGap"]! + viewMetrics["accessoryAllowance"]!
        let initialBoundingSize = CGSize(width: width - horizontalSpacing, height: CGFloat.max)
        let messageSize = messageString.boundingRectWithSize(initialBoundingSize, options: ObjCUtil.standardStringDrawingOptions(), attributes: attributes, context: nil).size
        
        let height = max(messageSize.height + 42,66.0)
        return height
    }
    
    var thread:MessageThread! = nil {
        didSet {
            if(thread != nil) {
                updateViewForThread(thread)
            }
        }
    }
    
    lazy var profileImage:MaskedImageView = {
        let image:MaskedImageView = MaskedImageView()
        image.setTranslatesAutoresizingMaskIntoConstraints(false)
        return image
    }()
    
    lazy var recipientLabel: UILabel = {
        let label:UILabel = UILabel()
        label.font = InterfaceConfiguration.mainEmphasisFont
        label.textColor = UIColor.blackColor()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label:UILabel = UILabel()
        label.font = InterfaceConfiguration.contentFont
        label.textColor = UIColor.blackColor()
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(800, forAxis: UILayoutConstraintAxis.Vertical)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label:UILabel = UILabel()
        label.font = InterfaceConfiguration.smallDetailFont
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Right
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    lazy var dataManager:KinveyDataManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.dataManager
    }()
    
    lazy var dateFormatter:NSDateFormatter = {
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    func setupSubviews() {
        accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        contentView.addSubview(profileImage)
        contentView.addSubview(recipientLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        
        let views = [
            "profileImage" : profileImage,
            "recipientLabel" : recipientLabel,
            "contentLabel" : contentLabel,
            "timeLabel" : timeLabel
        ]
        
        let constraintsFormats = [
            "V:|-(outerGap)-[profileImage(==picSize)]",
            "H:|-(outerGap)-[profileImage(==picSize)]-(outerGap)-[recipientLabel(>=minRecipientWidth)]",
            "V:|-(timeGap)-[timeLabel]",
            "H:[timeLabel(>=minTimeWidth)]-(timeGap)-|",
            "H:[profileImage]-(outerGap)-[contentLabel]-(timeGap)-|",
            "V:|-(outerGap)-[recipientLabel(==21)]-(5)-[contentLabel]-(>=outerGap)-|"
        ]
        
        var newConstraints:[NSLayoutConstraint] = []
        
        for format:String in constraintsFormats {
            let formatConstraints:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(0), metrics: MessageThreadTableViewCell.viewMetrics, views: views) as [NSLayoutConstraint]
            newConstraints += formatConstraints
        }
        
        contentView.addConstraints(newConstraints)
    }
    
    override func prepareForReuse() {
        // Clear out all state from previous user
        //profileImage.image = nil
        recipientLabel.text = nil
        contentLabel.text = nil
        timeLabel.text = nil
    }
    
    func updateViewForThread(thread:MessageThread) {
        if(thread.lastMessage != nil) {
            self.timeLabel.text = dateFormatter.stringFromDate(thread.lastMessage.getDateForSort())
            self.contentLabel.text = thread.lastMessage.messageText
        } else {
            self.timeLabel.text = ""
            self.contentLabel.text = ""
        }
        
        self.setNeedsLayout()
        
        let user = dataManager.fetchUserFromThread(thread)
        self.recipientLabel.text = user.givenName + " " + user.surname
        
        
        let pictureId = user.getValueForAttribute(kWaterCoolerUserProfilePicFileId) as String!
        if(pictureId == nil) {
            return
        }
        
        self.profileImage.image = nil
        if let userProfileImage = user.getProfileImage() {
            profileImage.image = userProfileImage
        } else {
            user.populateProfileImage { (image) -> () in
                self.profileImage.image = image
            }
        }
        
    }
    
}

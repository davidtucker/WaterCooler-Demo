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
    
    //MARK: - Class Methods and Properties
    
    /*
        This method is used to calculate the height of the message text.  Ideally
        this would be automatic using UITableViewAutomaticDimension, but there was
        an issue with iOS 8.0 which would cause a visual flash when using this.  That
        being said, we are going to leverage an explicit row height, and this method
        facilitates determining the height based on the height of the message text.
    */
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
    
    /*
        These are the view metrics that are leveraged both by the heightForMessageText
        and the auto-layout constraints for the view.
    */
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
    
    //MARK: - UIView Component Definition and Creation
    
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
    
    //MARK: - Data Manager
    
    lazy var dataManager:KinveyDataManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.dataManager
    }()
    
    //MARK: - Initialization and View Setup
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    /*
        This method adds the subviews and sets up the needed auto-layout constraints
        for the view.
    */
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
    
    //MARK: - Customization of the View for Data
    
    /*
        The thread property that gets assigned to the cell.  When it is set, it calls
        updateViewForThread which actually updates the state of the subviews.
    */
    var thread:MessageThread! = nil {
        didSet {
            if(thread != nil) {
                updateViewForThread(thread)
            }
        }
    }
    
    /*
        This method updates the cell when a new thread is assigned to the cell.
    */
    func updateViewForThread(thread:MessageThread) {
        if(thread.lastMessage != nil) {
            self.timeLabel.text = InterfaceConfiguration.formattedDate(DateFormat.Short, date: thread.lastMessage.getDateForSort())
            self.contentLabel.text = thread.lastMessage.messageText
        } else {
            self.timeLabel.text = ""
            self.contentLabel.text = ""
        }
        
        self.setNeedsLayout()
        
        if let user = dataManager.fetchUserFromThread(thread) {
            self.recipientLabel.text = user.givenName + " " + user.surname
            if let pictureId = user.profilePictureId {
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
    }
    
    /*
        This method clears out the cell before a new thread gets assigned to it.
        It purposefully does not clear the profile pic to avoid a visual flash when
        reusing a cell.
    */
    override func prepareForReuse() {
        recipientLabel.text = nil
        contentLabel.text = nil
        timeLabel.text = nil
    }
    
}

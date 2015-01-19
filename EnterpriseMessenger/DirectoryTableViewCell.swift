//
//  DirectoryTableViewCell.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/21/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class DirectoryTableViewCell : UITableViewCell {
    
    lazy var profileImage:MaskedImageView = {
        let image:MaskedImageView = MaskedImageView()
        image.setTranslatesAutoresizingMaskIntoConstraints(false)
        return image
    }()
    
    lazy var nameLabel:UILabel = {
        let label:UILabel = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18.0)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    lazy var titleLabel:UILabel = {
        let label:UILabel = UILabel()
        label.font = UIFont(name: "HelveticaNeue-LightItalic", size: 14.0)
        label.textColor = UIColor.lightGrayColor()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
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
        contentView.addSubview(nameLabel)
        contentView.addSubview(titleLabel)
        
        let views = [
            "nameLabel" : nameLabel,
            "titleLabel" : titleLabel,
            "profileImage" : profileImage
        ]
        
        let metrics = [
            "topPicMargin" : 8.0,
            "topLabelMargin" : 11.0,
            "leftMargin" : 11.0,
            "hGap" : 11.0,
            "vGap" : 3.0,
            "rightMargin" : 30.0,
            "bottomMargin" : 8.0
        ]
        
        let constraintsFormats = [
            "V:|-(topPicMargin)-[profileImage(==50)]",
            "H:|-(leftMargin)-[profileImage(==50)]-(hGap)-[nameLabel]-(rightMargin)-|",
            "H:[profileImage]-(hGap)-[titleLabel]-(rightMargin)-|",
            "V:|-(topLabelMargin)-[nameLabel]-(vGap)-[titleLabel]"
        ]
        
        var newConstraints:[NSLayoutConstraint] = []
        
        for format:String in constraintsFormats {
            let formatConstraints:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(0), metrics: metrics, views: views) as [NSLayoutConstraint]
            newConstraints += formatConstraints
        }
        
        contentView.addConstraints(newConstraints)
    }
    
    var user:KCSUser! = nil {
        didSet {
            // Set State if We Have a New User
            if(user != nil) {
                updateViewForUser(user)
            }
        }
    }
    
    override func prepareForReuse() {
        // Clear out all state from previous user
        profileImage.image = nil
        nameLabel.text = nil
        titleLabel.text = nil
    }
    
    private func updateViewForUser(user:KCSUser) {
        nameLabel.text = user.givenName + " " + user.surname
        titleLabel.text = user.getValueForAttribute(kWaterCoolerUserTitleValue) as String!
        
        if let userProfileImage = user.getProfileImage() {
            profileImage.image = userProfileImage
        } else {
            user.populateProfileImage { (image) -> () in
                self.profileImage.image = image
            }
        }
        
    }
    
}
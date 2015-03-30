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
    
    //MARK: - UIView Component Creation
    
    lazy var profileImage:MaskedImageView = {
        let image:MaskedImageView = MaskedImageView()
        image.setTranslatesAutoresizingMaskIntoConstraints(false)
        return image
    }()
    
    lazy var nameLabel:UILabel = {
        let label:UILabel = UILabel()
        label.font = InterfaceConfiguration.cellTitleFont
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    lazy var titleLabel:UILabel = {
        let label:UILabel = UILabel()
        label.font = InterfaceConfiguration.cellSubtitleFont
        label.textColor = UIColor.lightGrayColor()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    //MARK: - Init & Creation
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    /*
        This method is called when the cell is initialized.  It will lazily create
        the UIViews for the view.  Then it will add these and  setup the needed
        auto-layout constraints.
    */
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
    
    //MARK: - Properties
    
    /*
        This property is the data for the cell.  When you assign a user to a cell,
        it uses the Swift didSet closure to call the updateViewForUser method.
    */
    var user:KCSUser! = nil {
        didSet {
            // Set State if We Have a New User
            if(user != nil) {
                updateViewForUser(user)
            }
        }
    }
    
    /*
        In this method, we'll clear out anything that needs to be cleared out
        before being reused.  Most of this will get reset when adding a new user.
        We specifically aren't clearing the profile image as we don't want the
        image to 'flash' when changing to a new user.
    */
    override func prepareForReuse() {
        // Clear out all state from previous user
        profileImage.image = nil
        nameLabel.text = nil
        titleLabel.text = nil
    }
    
    /*
        This private method updates the cell based on the user property that has
        been assigned.
    */
    private func updateViewForUser(user:KCSUser) {
        nameLabel.text = user.givenName + " " + user.surname
        titleLabel.text = user.title
        
        if let userProfileImage = user.getProfileImage() {
            profileImage.image = userProfileImage
        } else {
            self.profileImage.image = nil
            user.populateProfileImage { (image) -> () in
                self.profileImage.image = image
            }
        }
    }
    
}
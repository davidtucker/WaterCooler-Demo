//
//  SignupViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/20/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController : UserDetailBaseViewController, UITextFieldDelegate {
    
    lazy var resetButton:UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Reset", style: .Plain, target: self, action: "resetProfile:")
        return button
    }()
    
    lazy var saveButton:UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "saveProfile:")
        return button
    }()
    
    override func profileMode() -> ProfileMode {
        return ProfileMode.UserProfile
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.user = KCSUser.activeUser()
        profileView.scrollView.contentInset = UIEdgeInsetsMake(60.0, 0, 0, 0);
        hideActions()
    }
    
    func showActions() {
        self.tabBarController?.navigationItem.setLeftBarButtonItems([resetButton], animated: true)
        self.tabBarController?.navigationItem.setRightBarButtonItems([saveButton], animated: true)
    }
    
    func hideActions() {
        self.tabBarController?.navigationItem.setLeftBarButtonItems(nil, animated: true)
        self.tabBarController?.navigationItem.setRightBarButtonItems(nil, animated: true)
    }
    
    func resetProfile(sender:AnyObject) {
        profileView.user = KCSUser.activeUser()
        self.view.endEditing(true)
        hideActions()
    }
    
    func saveProfile(sender:AnyObject) {
        let hud = presentIndeterminiteMessage("Saving User")
        
        if profileView.hasProfilePictureChanged && (profileView.photoImageView.image == nil) {
            updateUser(KCSUser.activeUser(), profilePicId: nil)
            deleteProfilePicture(KCSUser.activeUser(), completion: { () -> () in
                self.updateKinveyUser(KCSUser.activeUser(), completion: { (savedUser) -> () in
                    self.profileView.user = KCSUser.activeUser()
                    hud.hide(true)
                })
            })
        } else if profileView.hasProfilePictureChanged {
            deleteProfilePicture(KCSUser.activeUser(), completion: { () -> () in
                if let image = self.profileView.photoImageView.image {
                    self.uploadProfilePicture(image, completion: { (file) -> () in
                        if let photoId = file.fileId {
                            self.updateUser(KCSUser.activeUser())
                            self.assignProfilePictureIdToUser(KCSUser.activeUser(), picture: file, completion: { () -> Void in
                                hud.hide(true)
                                self.dataManager.invalidateImageCacheForUser(KCSUser.activeUser())
                                self.profileView.user = KCSUser.activeUser()
                            })
                        }
                    })
                }
                
            })
        } else {
            updateUser(KCSUser.activeUser())
            updateKinveyUser(KCSUser.activeUser(), completion: { (savedUser) -> () in
                self.profileView.user = KCSUser.activeUser()
                hud.hide(true)
            })
        }
    }
    
    func updateUser(user:KCSUser) {
        KCSUser.activeUser().givenName = profileView.firstNameField.text
        KCSUser.activeUser().surname = profileView.lastNameField.text
        KCSUser.activeUser().title = profileView.titleTextField.text!
        KCSUser.activeUser().email = profileView.emailTextField.text
        KCSUser.activeUser().username = profileView.emailTextField.text
    }
    
    func updateUser(user:KCSUser, profilePicId:String?) {
        updateUser(user)
        KCSUser.activeUser().profilePictureId = profilePicId
    }
    
    func udpateAndSaveUser(user:KCSUser, completion: (user:KCSUser) -> ()) {
        
        
        
    }
    
    //MARK: --
    //MARK: ProfileViewDelegate Implementation
    
    func userProfileStateDidChange(isDirty:Bool) {
        if(isDirty) {
            showActions()
        } else {
            hideActions()
        }
    }
    
}
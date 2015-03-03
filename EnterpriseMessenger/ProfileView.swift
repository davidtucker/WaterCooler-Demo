//
//  ProfileView.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/28/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

enum ProfileMode {
    case Signup
    case UserProfile
    case DirectoryDetail
}

@objc protocol ProfileViewDelegate : NSObjectProtocol {
    
    optional func emailUserAtAddress(address:String) -> Void
    optional func messageUser(user:KCSUser) -> Void
    optional func logoutCurrentUser() -> Void
    optional func changePasswordForCurrentUser() -> Void
    optional func userDidPressPhotoButton() -> Void
    optional func profileDidChangeCompletionStatus(isComplete:Bool) -> Void
    optional func userProfileStateDidChange(isDirty:Bool) -> Void
    
}

@objc(ProfileView)

class ProfileView : UIView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var photoImageView: MaskedImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    
    lazy var tapRecognizer:UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: "imageTap:")
        recognizer.delegate = self
        return recognizer
    }()
    
    weak var delegate:ProfileViewDelegate?
    
    var profileMode:ProfileMode = .Signup {
        didSet {
            setupViewForMode()
        }
    }
    
    var isProfileComplete:Bool = false {
        didSet {
            if(oldValue != isProfileComplete) {
                delegate?.profileDidChangeCompletionStatus?(isProfileComplete)
            }
        }
    }
    
    var hasUserProfileChanged:Bool = false {
        didSet {
            if(oldValue != hasUserProfileChanged) {
                delegate?.userProfileStateDidChange?(hasUserProfileChanged)
            }
        }
    }
    
    var hasProfilePictureChanged:Bool = false
    
    var user:KCSUser? = nil {
        didSet {
            updateViewForUser()
        }
    }
    
    var photoImage:UIImage? = nil {
        didSet {
            hasProfilePictureChanged = true
            evaluateUserProfileChanges()
            photoImageView.image = photoImage;
            if(photoImage != nil) {
                setProfilePictureState(true)
            } else {
                setProfilePictureState(false)
            }
        }
    }
    
    func setProfilePictureState(populated:Bool) {
        if(photoImageView.image != nil) {
            photoImageView.hidden = false;
            photoImageView.alpha = 1.0;
            addImageButton.alpha = 0.0;
        } else {
            photoImageView.hidden = true;
            addImageButton.alpha = 1.0;
            photoImageView.image = nil;
        }
    }
    
    func imageTap(sender:AnyObject) {
        userDidPressPhoto(sender)
    }
    
    private func updateViewForUser() {
        firstNameField.text = user?.givenName
        lastNameField.text = user?.surname
        emailTextField.text = user?.email
        titleTextField.text = user?.title
        
        hasProfilePictureChanged = false
        evaluateUserProfileChanges()
        
        if(user?.hasProfileImage() == false) {
            photoImageView.image = nil
            setProfilePictureState(false)
            return
        }
        
        if let image = user?.getProfileImage() {
            photoImageView.image = image
            setProfilePictureState(true)
        } else {
            user?.populateProfileImage({ (image) -> () in
                self.photoImageView.image = image
                self.setProfilePictureState(true)
            })
        }
    }
    
    private func setupViewForMode() {
        passwordContainerView.hidden = (profileMode != .Signup)
        changePasswordButton.hidden = (profileMode != .UserProfile)
        logoutButton.hidden = (profileMode != .UserProfile)
        emailButton.hidden = (profileMode != .DirectoryDetail)
        messageButton.hidden = (profileMode != .DirectoryDetail)
        photoImageView.userInteractionEnabled = true
        photoImageView.addGestureRecognizer(tapRecognizer)
        configureAddPhotoButton()
    }
    
    func configureAddPhotoButton() {
        let addPhotoImage:UIImage = UIImage(named: "Add Photo")!;
        let maskImage:UIImage = UIImage(named: "CircleMask")!;
        let maskedImage:UIImage = UIImage.maskedImage(image: addPhotoImage, withMask: maskImage);
        addImageButton.setImage(maskedImage, forState: UIControlState.Normal);
    }
    
    private func isEditable() -> Bool {
        return (profileMode != .DirectoryDetail)
    }
    
    //MARK: --
    //MARK: UITextFieldDelegate Implementation
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return isEditable()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == firstNameField) {
            lastNameField.becomeFirstResponder()
        } else if(textField == lastNameField) {
            emailTextField.becomeFirstResponder()
        } else if(textField == emailTextField) {
            titleTextField.becomeFirstResponder()
        } else if(textField == titleTextField) {
            if(passwordContainerView.hidden) {
                textField.resignFirstResponder()
            } else {
                passwordField.becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: --
    //MARK: IBActions
    
    @IBAction func emailUser(sender:AnyObject) {
        delegate?.emailUserAtAddress?(user!.email!)
    }
    
    @IBAction func messageUser(sender:AnyObject) {
        delegate?.messageUser?(user!)
    }
    
    @IBAction func logout(sender:AnyObject) {
        delegate?.logoutCurrentUser?()
    }
    
    @IBAction func changePassword(sender:AnyObject) {
        delegate?.changePasswordForCurrentUser?()
    }
    
    @IBAction func userDidPressPhoto(sender:AnyObject) {
        if(isEditable()) {
            delegate?.userDidPressPhotoButton?()
        }
    }
    
    @IBAction func textFieldDidChange(sender:AnyObject) {
        if(user != nil) {
            evaluateUserProfileChanges()
        }
        evaluateCompletionStatus()
    }
    
    func evaluateUserProfileChanges() {
        if(hasProfilePictureChanged) {
            hasUserProfileChanged = true
            return
        }
        
        if(user?.title != titleTextField.text) {
            hasUserProfileChanged = true
            return
        }
        
        if(user?.givenName != firstNameField.text) {
            hasUserProfileChanged = true
            return
        }
        
        if(user?.surname != lastNameField.text) {
            hasUserProfileChanged = true
            return
        }
        
        if(user?.email != emailTextField.text) {
            hasUserProfileChanged = true
            return
        }
        
        hasUserProfileChanged = false
    }
    
    func evaluateCompletionStatus() {
        if(isTextFieldValid(firstNameField) &&
            isTextFieldValid(lastNameField) &&
            isTextFieldValid(emailTextField) &&
            isTextFieldValid(titleTextField) &&
            isTextFieldValid(passwordField)) {
                isProfileComplete = true
        } else {
            isProfileComplete = false;
        }
    }
    
    func isTextFieldValid(field:UITextField) -> Bool {
        return countElements(field.text) > 0;
    }
    
}
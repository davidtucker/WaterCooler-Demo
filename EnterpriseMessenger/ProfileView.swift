//
//  ProfileView.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/28/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

/*
    This view can be used in one of 3 different ways.  This is an enum to 
    enumerate these three options.
*/
enum ProfileMode {
    case Signup
    case UserProfile
    case DirectoryDetail
}

//MARK: - Delegate Protocol

/*
    The delegate protocol covers all three use cases of this view.  That being
    said, all of the options are optional (because some are used in some use
    cases and not others.  

    To allow for optional protocol methods, the protocol has to extend
    NSObjectProtocol and be declared as an '@objc' protocol.
*/
@objc protocol ProfileViewDelegate : NSObjectProtocol {
    
    optional func emailUserAtAddress(address:String) -> Void
    optional func messageUser(user:KCSUser) -> Void
    optional func logoutCurrentUser() -> Void
    optional func changePasswordForCurrentUser() -> Void
    optional func userDidPressPhotoButton() -> Void
    optional func profileDidChangeCompletionStatus(isComplete:Bool) -> Void
    optional func userProfileStateDidChange(isDirty:Bool) -> Void
    
}

//MARK: - Class Definition

@objc(ProfileView)

/*
    This class represents a reusable UIView that is used in three different
    places within the application: the signup form, the user profile screen, and
    the directory user detail view.  

    This view has a xib (ProfileView.xib) which it will be loaded from.
*/
class ProfileView : UIView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    //MARK: - IBOutlets
    
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
    
    //MARK: - Properties
    
    /*
        This is the delegate for the view.  All interaction with the view controller
        happen through this delegate.  It is a weak reference (as all delegates
        generally should be).
    */
    weak var delegate:ProfileViewDelegate?
    
    /*
        This gesture recognizer is used to detect any taps on the profile image (which
        is used when the user wants to edit or delete their profile image.
    */
    lazy var tapRecognizer:UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: "imageTap:")
        recognizer.delegate = self
        return recognizer
    }()
    
    /*
        This defines the mode for this view.  Since it can be displayed in one of
        three modes, any change to the mode will call the setupViewForMode() method.
    */
    var profileMode:ProfileMode = .Signup {
        didSet {
            setupViewForMode()
        }
    }
    
    /*
        This property is leveraged for the signup view and will trigger a call to the
        delegate if the value changes for form completion.
    */
    var isProfileComplete:Bool = false {
        didSet {
            if(oldValue != isProfileComplete) {
                delegate?.profileDidChangeCompletionStatus?(isProfileComplete)
            }
        }
    }
    
    /*
        This property is leveraged to track changes to the profile from the original
        user object.  If the value changes, a delegate call will be triggered.
    */
    var hasUserProfileChanged:Bool = false {
        didSet {
            if(oldValue != hasUserProfileChanged) {
                delegate?.userProfileStateDidChange?(hasUserProfileChanged)
            }
        }
    }
    
    /*
        This property tracks if the profile picture has changed.  This is important
        to know so that we can know if we need to save something new to the Kinvey
        file store.
    */
    var hasProfilePictureChanged:Bool = false
    
    /*
        This is the KCSUser that the view is being based on.  For the signup mode,
        this value will be nil.
    */
    var user:KCSUser? = nil {
        didSet {
            updateViewForUser()
        }
    }
    
    /*
        This is the profile image for the user.  Updating this value will update the
        view state for the image.
    */
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
    
    //MARK: - User Interaction and View Configuration
    
    /*
        This method updates the state of the image view for the profile picture as well
        as the image which is displayed when there is no profile picture selected.
    */
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
    
    /*
        This method is called when the tap gesture recognizer is triggered on the image.
    */
    func imageTap(sender:AnyObject) {
        userDidPressPhoto(sender)
    }
    
    /*
        This method updates the view state based on the KCSUser instance which was set
        with the user property.
    */
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
    
    /*
        This method configures the view based on the mode which the view is currently
        set in.  This will hide / show some subviews as well as adding the tap
        gesture recognizer (if needed).
    */
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
    
    /*
        This method configures the Add Photo button with the mask to match the Masked
        Image View.
    */
    func configureAddPhotoButton() {
        let addPhotoImage:UIImage = UIImage(named: "Add Photo")!;
        let maskImage:UIImage = UIImage(named: "CircleMask")!;
        let maskedImage:UIImage = UIImage.maskedImage(image: addPhotoImage, withMask: maskImage);
        addImageButton.setImage(maskedImage, forState: UIControlState.Normal);
    }
    
    //MARK: - UITextFieldDelegate Implementation
    
    /*
        This is the method which the text fields call to know if they are editable.
        We use the isEditable method to determine the state based on the current
        mode.
    */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return isEditable()
    }
    
    /*
        This delegate method for UITextField dictates what happens with the user
        presses the return key.
    */
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
    
    //MARK: - IBActions
    
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
    
    //MARK: - Private Methods
    
    /*
        This method is called in several different scenarios (for example when a
        text field changes) to determine if the profile has changed from its
        original state.
    */
    private func evaluateUserProfileChanges() {
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
    
    /*
        This method determined if the form is editable based on the mode.
    */
    private func isEditable() -> Bool {
        return (profileMode != .DirectoryDetail)
    }
    
    /*
        This method evaluates the profile completion state based on the values
        in the text fields.
    */
    private func evaluateCompletionStatus() {
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
    
    /*
        This is the method that we use to determine if the value entered in a text
        field is a valid value.  In this case, it needs to not be empty.
    */
    private func isTextFieldValid(field:UITextField) -> Bool {
        return countElements(field.text) > 0;
    }
    
}
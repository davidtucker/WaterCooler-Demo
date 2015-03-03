//
//  UserDetailBaseViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/28/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

class UserDetailBaseViewController : UIViewController, ProfileViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var profileView:ProfileView = {
        let profileView = NSBundle.mainBundle().loadNibNamed("ProfileView", owner: self, options: nil)[0] as? ProfileView
        profileView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        profileView!.profileMode = self.profileMode()
        profileView!.delegate = self
        return profileView!
    }()
    
    lazy var dataManager:KinveyDataManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.dataManager
    }()
    
    override func viewDidLoad() {
        setupSubviews()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        addKeyboardHandlers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeKeyboardHandlers()
    }
    
    func setupSubviews() {
        view.addSubview(profileView)
        
        let views = [
            "profile" : profileView
        ]
        
        let constraintsFormats = [
            "V:|-(0)-[profile]-(0)-|",
            "H:|-(0)-[profile]-(0)-|"
        ]
        
        var newConstraints:[NSLayoutConstraint] = []
        
        for format:String in constraintsFormats {
            let formatConstraints:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(0), metrics: nil, views: views) as [NSLayoutConstraint]
            newConstraints += formatConstraints
        }
        
        view.addConstraints(newConstraints)
    }
    
    func profileMode() -> ProfileMode {
        assert(false, "Must Implement in Subclass")
    }
    
    //MARK: --
    //MARK: Keyboard Handling
    
    func addKeyboardHandlers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardHandlers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue().size
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height + 50.0, 0.0)
        profileView.scrollView.contentInset = contentInsets
        profileView.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let contentInsets = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0)
        profileView.scrollView.contentInset = contentInsets
        profileView.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func presentPhotoAlertController() {
        let alertController = UIAlertController(title: nil, message: "Select which method of collecting your photo.", preferredStyle: .ActionSheet);
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Photo Library", style: .Default) { (action) in
            self.presentPhotoLibrary(UIImagePickerControllerSourceType.PhotoLibrary);
        }
        alertController.addAction(OKAction)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (action) in
            self.presentPhotoLibrary(UIImagePickerControllerSourceType.Camera);
        }
        alertController.addAction(cameraAction)
        
        if(profileView.photoImageView.image != nil) {
            let deleteAction = UIAlertAction(title: "Delete Photo", style: .Destructive) { (action) in
                self.profileView.photoImage = nil
            }
            alertController.addAction(deleteAction)
        }
        
        self.presentViewController(alertController, animated: true) {
            
        }
    }
    
    func presentPhotoLibrary(sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController();
        pickerController.delegate = self;
        pickerController.sourceType = sourceType;
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
        });
        
        var selectedImage:UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage;
        if(selectedImage == nil) {
            selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage;
        }
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue) { () -> Void in
            var squareImage = selectedImage?.squareCroppedImage(500.0);
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.profileView.photoImage = squareImage;
            })
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil);
    }
    
    //MARK: --
    //MARK: UINavigationControllerDelegate Implementation
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent;
    }
    
    //MARK: --
    //MARK: ProfileViewDelegate Implementation
    
    func emailUserAtAddress(address:String) {
        let urlString = "mailto:" + address
        let url = NSURL(string: urlString)
        let result = UIApplication.sharedApplication().openURL(url!)
        if(!result) {
            alertUserThatApplicationCannotSendEmail()
        }
    }
    
    func logoutCurrentUser() {
        KCSUser.activeUser().logout()
        performSegueWithIdentifier(WaterCoolerConstants.Segue.Logout, sender: self)
    }
    
    func changePasswordForCurrentUser() {
        performSegueWithIdentifier(WaterCoolerConstants.Segue.ChangePassword, sender: self)
    }
    
    func alertUserThatApplicationCannotSendEmail() {
        let alert = UIAlertController(title: "Email Error", message: "Please configure the iOS Mail application if you wish to email from this application.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func userDidPressPhotoButton() {
        presentPhotoAlertController()
    }
    
}

//MARK: -
//MARK: Kinvey User Creation Process

extension UserDetailBaseViewController {
    
    @IBAction func createUser() {
        
        let hud = presentIndeterminiteMessage("Creating User")
        
        // Perform User Creation and Profile Picture Uploading
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue) { () -> Void in
            
            // Perform the User Creation
            self.createKinveyUser({ (user) -> () in
                
                // When user creation completion, dismiss the signup view controller on the main thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    hud.hide(true)
                    self.dismissViewControllerAnimated(true, completion: nil);
                })
                
            })
            
        }
        
    }
    
    func uploadProfilePicture(image:UIImage, completion:(file:KCSFile!) -> ()) {
        if((profileView.photoImage) != nil) {
            let photoData = UIImageJPEGRepresentation(image, 1.0)
            
            let metadata = KCSMetadata();
            metadata.setGloballyReadable(true);
            
            var fileParams = [ KCSFileMimeType : "image/jpeg",
                KCSFileACL : metadata ];
            
            KCSFileStore.uploadData(photoData, options: fileParams, completionBlock: { (file:KCSFile!, error:NSError!) -> Void in
                completion(file: file);
                }, progressBlock: nil);
            
        } else {
            completion(file: nil);
        }
    }
    
    func deleteProfilePicture(user:KCSUser, completion: () -> ()) {
        let fileId = user.profilePictureId
        if(fileId == nil || fileId!.isEmpty) {
            completion()
        } else {
            KCSFileStore.deleteFile(fileId, completionBlock: { (count, error) -> Void in
                if(error != nil) {
                    println("Error deleting profile pic: " + error.localizedDescription)
                }
                completion()
            })
        }
    }
    
    func createKinveyUser(completion: (KCSUser!) -> ()) {
        
        // Set the parameters of the profile file upload
        var userParams = [ KCSUserAttributeGivenname : profileView.firstNameField.text,
            KCSUserAttributeSurname : profileView.lastNameField.text,
            KCSUserAttributeEmail : profileView.emailTextField.text,
            kWaterCoolerUserTitleValue : profileView.titleTextField.text
        ];
        
        // Save the user to Kinvey
        KCSUser.userWithUsername(profileView.emailTextField.text, password: profileView.passwordField.text, fieldsAndValues: userParams) { (user:KCSUser!, error:NSError!, result:KCSUserActionResult) in
            if(error != nil) {
                println("USER NOT CREATED - ERROR: " + error.description)
            } else {
                self.uploadProfilePicture(self.profileView.photoImageView.image!, { (file) -> () in
                    self.assignProfilePictureIdToUser(user, picture:file) { () -> Void in
                        completion(user);
                    }
                })
            }
        }
    }
    
    func updateKinveyUser(user:KCSUser, completion:(KCSUser!) -> ()) {
        user.saveWithCompletionBlock { (results, error) -> Void in
            if(error != nil) {
                self.presentErrorMessage(error)
            } else {
                completion(results[0] as KCSUser)
            }
        }
    }
    
    func assignProfilePictureIdToUser(user:KCSUser, picture:KCSFile, completion: () -> Void) {
        user.setValue(picture.kinveyObjectId(), forAttribute: kWaterCoolerUserProfilePicFileId);
        user.saveWithCompletionBlock { (user:[AnyObject]!, error:NSError!) -> Void in
            completion();
        }
    }
    
}
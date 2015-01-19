//
//  SignupViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/20/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var addPhoto: UIButton!
    @IBOutlet weak var photo: MaskedImageView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var photoImage:UIImage? = nil {
        didSet {
            if(photoImage != nil) {
                photo.hidden = false;
                photo.alpha = 1.0;
                addPhoto.alpha = 0.1;
                photo.image = photoImage;
            } else {
                photo.hidden = true;
                addPhoto.alpha = 1.0;
                photo.image = nil;
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        photo.hidden = true;
        configureAddPhotoButton();
        addKeyboardHandlers();
    }

    func addKeyboardHandlers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let currentView:UIScrollView = self.view as UIScrollView;
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        currentView.contentInset = contentInsets
        currentView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let currentView:UIScrollView = self.view as UIScrollView;
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0)
        currentView.contentInset = contentInsets
        currentView.scrollIndicatorInsets = contentInsets
    }
    
    func configureAddPhotoButton() {
        let addPhotoImage:UIImage = UIImage(named: "Add Photo")!;
        let maskImage:UIImage = UIImage(named: "CircleMask")!;
        let maskedImage:UIImage = UIImage.maskedImage(image: addPhotoImage, withMask: maskImage);
        addPhoto.setImage(maskedImage, forState: UIControlState.Normal);
    }
    
    @IBAction func cancelSignup() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            // Dismiss View Controller
        });
    }
    
    @IBAction func presentPhotoAlertController() {
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
        
        self.presentViewController(alertController, animated: true) {
            
        }
    }
    
    func presentPhotoLibrary(sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController();
        pickerController.delegate = self;
        pickerController.sourceType = sourceType;
        
        self.presentViewController(pickerController, animated: true, completion: { () -> Void in
            // Presented
        })
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
                self.photoImage = squareImage;
            })
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == firstNameField) {
            lastNameField.becomeFirstResponder();
        } else if(textField == lastNameField) {
            emailField.becomeFirstResponder();
        } else if(textField == emailField) {
            titleField.becomeFirstResponder();
        } else if(textField == titleField) {
            passwordField.becomeFirstResponder();
        } else {
            textField.resignFirstResponder();
        }

        return true;
    }
    
    @IBAction func evaluateCompletionStatus() {
        if(isTextFieldValid(firstNameField) &&
            isTextFieldValid(lastNameField) &&
            isTextFieldValid(emailField) &&
            isTextFieldValid(titleField) &&
            isTextFieldValid(passwordField)) {
                doneButton.enabled = true;
        } else {
            doneButton.enabled = false;
        }
    }
    
    func isTextFieldValid(field:UITextField) -> Bool {
        return countElements(field.text) > 0;
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        });
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent;
    }

}

//MARK: -
//MARK: Kinvey User Creation Process


extension SignupViewController {
    
    @IBAction func createUser() {
        
        // Perform User Creation and Profile Picture Uploading
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue) { () -> Void in
            
            // Perform the User Creation
            self.createKinveyUser({ (user) -> () in
                
                // When user creation completion, dismiss the signup view controller on the main thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil);
                })
                
            })
            
        }
        
    }
    
    func uploadProfilePicture(completion:(file:KCSFile!) -> ()) {
        if((self.photo.image) != nil) {
            let photoData = UIImageJPEGRepresentation(self.photo.image, 1.0)
            
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
    
    func createKinveyUser(completion: (KCSUser!) -> ()) {
        
        // Set the parameters of the profile file upload
        var userParams = [ KCSUserAttributeGivenname : firstNameField.text,
            KCSUserAttributeSurname : lastNameField.text,
            KCSUserAttributeEmail : emailField.text,
            kWaterCoolerUserTitleValue : titleField.text
        ];
        
        // Save the user to Kinvey
        KCSUser.userWithUsername(emailField.text, password: passwordField.text, fieldsAndValues: userParams) { (user:KCSUser!, error:NSError!, result:KCSUserActionResult) in
            if(error != nil) {
                println("USER NOT CREATED - ERROR: " + error.description)
            } else {
                self.uploadProfilePicture({ (file) -> () in
                    self.assignProfilePictureIdToUser(user, picture:file) { () -> Void in
                        completion(user);
                    }
                })
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
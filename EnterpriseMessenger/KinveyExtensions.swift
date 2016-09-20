//
//  KinveyExtensions.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/9/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

/*
    The following methods and properties are extensions of the core KCSUser object
    (which is provided in the Kinvey iOS SDK.
*/
extension KCSUser {
    
    /*
        This method is a convenience method to get the user's profile picture as a
        UIImage.  This leverages a cache that is defined within the app delegate.  If
        the image has not been saved in the cache, this will return nil.  If that
        happens, you can call populateProfileImage to populate the cache.
    */
    func getProfileImage() -> UIImage? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.dataManager.imageCache[self.userId]
    }
    
    /*
        This method populates the profile pic in the application cache for this user.
        Once this has been called, the profile pic can be fetched synchronously by
        using the getProfileImage method.
    */
    func populateProfileImage(completion:(UIImage?) -> ()) {
        let pictureId = self.getValueForAttribute(WaterCoolerConstants.Kinvey.ProfilePicIdField) as! String!
        if(pictureId == nil) {
            completion(nil)
        }
        var options = [ KCSFileOnlyIfNewer : true ]
        KCSFileStore.downloadFile(pictureId, options: options, completionBlock: { (result, error) -> Void in
            if(error == nil) {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let file:KCSFile = result[0] as! KCSFile
                let image:UIImage = UIImage(contentsOfFile: file.localURL.path!)!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    appDelegate.dataManager.imageCache[self.userId] = image
                    completion(image)
                })
            }
        }, progressBlock: nil)
    }
    
    /*
        This synchronous method allows us to check if a user has a profile picture
        in their user profile or not.
    */
    func hasProfileImage() -> Bool {
        let pictureId = self.getValueForAttribute(WaterCoolerConstants.Kinvey.ProfilePicIdField) as! String!
        if  pictureId != nil && !pictureId.isEmpty {
            return true
        }
        return false
    }
    
    /*
        This property handles the getting / setting of the profile picture ID for
        the user.  This uses Kinvey's ability to save arbitrary key-value data to
        the specific user.
    */
    var profilePictureId:String? {
        get {
            return self.getValueForAttribute(WaterCoolerConstants.Kinvey.ProfilePicIdField) as! String!
        }
        
        set {
            if(newValue != nil) {
                setValue(newValue, forAttribute: WaterCoolerConstants.Kinvey.ProfilePicIdField)
            } else {
                removeValueForAttribute(WaterCoolerConstants.Kinvey.ProfilePicIdField)
            }
        }
    }
    
    /*
        This property handles the getting / setting of the job title for the user.
        This uses Kinvey's ability to save arbitrary key-value data to the specific
        user.
    */
    var title:String {
        get {
            return self.getValueForAttribute(WaterCoolerConstants.Kinvey.UserTitleField) as! String!
        }
        
        set {
            setValue(newValue, forAttribute: WaterCoolerConstants.Kinvey.UserTitleField)
        }
    }
    
}

/*
    The following methods and properties are extensions of the core KCSMetadata object
    (which is provided in the Kinvey iOS SDK.
*/
extension KCSMetadata {
    
    /*
        This convenience initializer handles the configurating of permissions metadata.
        You can pass in an array of User ID's which will be allowed both read and write
        access to the data.  You can also add the active user without having to pass in
        the ID.
    */
    convenience init(userIds:[String], includeActiveUser:Bool) {
        self.init()
        var ids = userIds
        setGloballyReadable(false)
        setGloballyWritable(false)
        if(includeActiveUser) {
            ids.append(KCSUser.activeUser().userId)
        }
        for userId in ids {
            readers.addObject(userId)
            writers.addObject(userId)
        }
    }
    
}

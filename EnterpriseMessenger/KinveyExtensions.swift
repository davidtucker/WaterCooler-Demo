//
//  KinveyExtensions.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/9/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

let kWaterCoolerUserTitleValue = "title";
let kWaterCoolerUserProfilePicFileId = "profile_pic_id";

extension KCSUser {
    
    func getProfileImage() -> UIImage? {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.dataManager.imageCache[self.userId]
    }
    
    func populateProfileImage(completion:(UIImage?) -> ()) {
        let pictureId = self.getValueForAttribute(kWaterCoolerUserProfilePicFileId) as String!
        if(pictureId == nil) {
            completion(nil)
        }
        var options = [ KCSFileOnlyIfNewer : true ]
        KCSFileStore.downloadFile(pictureId, options: options, completionBlock: { (result, error) -> Void in
            if(error == nil) {
                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                let file:KCSFile = result[0] as KCSFile
                let image:UIImage = UIImage(contentsOfFile: file.localURL.path!)!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    appDelegate.dataManager.imageCache[self.userId] = image
                    completion(image)
                })
            }
        }, progressBlock: nil)
    }
    
    func hasProfileImage() -> Bool {
        let pictureId = self.getValueForAttribute(kWaterCoolerUserProfilePicFileId) as String!
        if  pictureId != nil && !pictureId.isEmpty {
            return true
        }
        return false
    }
    
    var profilePictureId:String? {
        get {
            return self.getValueForAttribute(kWaterCoolerUserProfilePicFileId) as String!
        }
        
        set {
            if(newValue != nil) {
                setValue(newValue, forAttribute: kWaterCoolerUserProfilePicFileId)
            } else {
                removeValueForAttribute(kWaterCoolerUserProfilePicFileId)
            }
        }
    }
    
    var title:String {
        get {
            return self.getValueForAttribute(kWaterCoolerUserTitleValue) as String!
        }
        
        set {
            setValue(newValue, forAttribute: kWaterCoolerUserTitleValue)
        }
    }
    
}

extension KCSMetadata {
    
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

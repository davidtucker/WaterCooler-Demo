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
    
    var title:String {
        return self.getValueForAttribute(kWaterCoolerUserTitleValue) as String!
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

extension NSDateFormatter {
    
    class func rfc3339Formatter() -> NSDateFormatter {
        let en_US_POSIX = NSLocale(localeIdentifier: "en_US_POSIX")
        let rfc3339DateFormatter = NSDateFormatter()
        rfc3339DateFormatter.locale = en_US_POSIX
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        rfc3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return rfc3339DateFormatter
    }
    
}

extension NSDate {
    
    class func dateFromRFC3339DateString(value:String) -> NSDate? {
        let formatter = NSDateFormatter.rfc3339Formatter()
        if var date = formatter.dateFromString(value) {
            return date
        }
        return nil
    }
    
}
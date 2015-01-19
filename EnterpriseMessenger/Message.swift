//
//  Message.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/27/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

let kWaterCoolerPushNotificationDictSenderIdKey = "senderId";
let kWaterCoolerPushNotificationDictMessageTextKey = "messageText";
let kWaterCoolerPushNotificationDictCreationDate = "creationDate";
let kWaterCoolerPushNotificationDictThreadIdKey = "threadId";
let kWaterCoolerPushNotificationDictEntityIdKey = "entityId";

class Message : NSObject, KCSPersistable {
    
    var entityId:String = ""
    var messageText:String!
    var senderId:String!
    var threadId:String!
    var userEntryTime:NSDate!
    var metadata:KCSMetadata! = nil
    
    override init() {}
    
    init(messageText:String, recipientId:String) {
        senderId = KCSUser.activeUser().userId
        self.messageText = messageText
        entityId = NSUUID().UUIDString
        metadata = KCSMetadata(userIds: [recipientId], includeActiveUser:true)
    }
    
    convenience init(userInfo:[NSObject : AnyObject]) {
        self.init()
        senderId = userInfo[kWaterCoolerPushNotificationDictSenderIdKey] as String
        messageText = userInfo[kWaterCoolerPushNotificationDictMessageTextKey] as String
        threadId = userInfo[kWaterCoolerPushNotificationDictThreadIdKey] as String
        let creationTime = userInfo[kWaterCoolerPushNotificationDictCreationDate] as String
        userEntryTime = NSDate.dateFromRFC3339DateString(creationTime)
        entityId = userInfo[kWaterCoolerPushNotificationDictEntityIdKey]! as String
    }
    
    func getDateForSort() -> NSDate {
        if let time = metadata?.creationTime() {
            return time
        }
        return userEntryTime
    }
    
    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        return [
            "entityId" : KCSEntityKeyId,
            "messageText" : "message",
            "senderId" : "senderId",
            "threadId" : "threadId",
            "metadata" : KCSEntityKeyMetadata
        ]
    }

}
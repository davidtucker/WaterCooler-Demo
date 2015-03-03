//
//  Message.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/27/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

class Message : NSObject, KCSPersistable {
    
    var entityId:String = ""
    var messageText:String!
    var senderId:String!
    var threadId:String!
    var userEntryTime:NSDate!
    var metadata:KCSMetadata! = nil
    
    override init() {}
    
    // This initializer creates a Message instance based on the message text
    // and the recipient ID.  This is the initializer that is used when a
    // user creates a new message in a conversation.
    init(messageText:String, recipientId:String) {
        senderId = KCSUser.activeUser().userId
        self.messageText = messageText
        entityId = NSUUID().UUIDString
        metadata = KCSMetadata(userIds: [recipientId], includeActiveUser:true)
    }
    
    /*
        This is a convenience initializer that is used to construct a message
        instance from the userInfo NSDictionary which is sent as the paylod of
        a push notification.
    */
    convenience init(userInfo:[NSObject : AnyObject]) {
        self.init()
        senderId = userInfo[WaterCoolerConstants.PushNotifications.SenderId] as String
        messageText = userInfo[WaterCoolerConstants.PushNotifications.MessageText] as String
        threadId = userInfo[WaterCoolerConstants.PushNotifications.ThreadId] as String
        let creationTime = userInfo[WaterCoolerConstants.PushNotifications.CreationDate] as String
        userEntryTime = NSDate.dateFromRFC3339DateString(creationTime)
        entityId = userInfo[WaterCoolerConstants.PushNotifications.EntityId]! as String
    }
    
    
    /*
        If we received the message via push notification, it won't have a populated
        creation time from the server - but will instead have a userEntryTime.  Due
        to that, we need to determine what time to sort by what is available.  The
        preference is for the creationTime via the server.
    */
    func getDateForSort() -> NSDate {
        if let time = metadata?.creationTime() {
            return time
        }
        return userEntryTime
    }
    
    /*
        This method maps the properties on this class to the properties in the
        Kinvey data store.  Note the predefined constants that you need to use
        for both the entityId and the metadata property.
    */
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

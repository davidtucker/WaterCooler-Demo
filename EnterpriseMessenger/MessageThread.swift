//
//  MessageThread.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/27/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

class MessageThread : NSObject, KCSPersistable {
    
    var entityId:String = ""
    var lastMessage:Message! = nil
    var metadata:KCSMetadata! = nil
    
    class func threadIdentifierForUser(user:KCSUser) -> String {
        let userAIdentifier:String = KCSUser.activeUser().userId
        let userBIdentifier:String = user.userId
        let identifiers:[String] = [ userAIdentifier, userBIdentifier ]
        let sortedIdentifiers = identifiers.sorted {
            $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending
        }
        return ":".join(sortedIdentifiers)
    }
    
    override init() {}
    
    init(user:KCSUser) {
        entityId = MessageThread.threadIdentifierForUser(user)
        metadata = KCSMetadata(userIds:[user.userId], includeActiveUser:true)
    }
    
    func getIntervalForSort() -> NSTimeInterval {
        if(lastMessage == nil) {
            return metadata.creationTime().timeIntervalSinceNow
        }
        return self.lastMessage.getDateForSort().timeIntervalSinceNow
    }
    
    // This method tells Kinvey to save the Message in the lastMessage property
    // when the thread is saved.  If this method were not included, the message
    // itself would not be saved when the thread is saved.
    override func referenceKinveyPropertiesOfObjectsToSave() -> [AnyObject]! {
        return [
            "lastMessage"
        ]
    }
    
    // This maps the properties in the class to specific values in the Kinvey
    // data store.
    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        return [
            "entityId" : KCSEntityKeyId,
            "lastMessage" : "lastMessage",
            "metadata" : KCSEntityKeyMetadata
        ]
    }
    
    // This method tells Kinvey that the lastMessage property is a member of
    // the Messages collection (you need to put the name of the Kinvey collection
    // here and not the name of the class)
    override class func kinveyPropertyToCollectionMapping() -> [NSObject : AnyObject]! {
        return [
            "lastMessage" : "Messages"
        ]
    }
    
    // Here you tell Kinvey which class to map the lastMessage property to. This
    // is how it knows how to build the object when it fetches it from the server.
    override class func kinveyObjectBuilderOptions() -> [NSObject : AnyObject]! {
        let referenceMap:[NSObject : AnyObject] = [
            "lastMessage" : Message.self
        ]
        return [
            KCS_REFERENCE_MAP_KEY : referenceMap
        ]
    }
    
}
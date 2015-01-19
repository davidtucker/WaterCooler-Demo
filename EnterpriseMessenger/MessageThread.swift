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
    
    override func referenceKinveyPropertiesOfObjectsToSave() -> [AnyObject]! {
        return [
            "lastMessage"
        ]
    }
    
    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        return [
            "entityId" : KCSEntityKeyId,
            "lastMessage" : "lastMessage",
            "metadata" : KCSEntityKeyMetadata
        ]
    }
    
    override class func kinveyPropertyToCollectionMapping() -> [NSObject : AnyObject]! {
        return [
            "lastMessage" : "Messages"
        ]
    }
    
    override class func kinveyObjectBuilderOptions() -> [NSObject : AnyObject]! {
        let referenceMap:[NSObject : AnyObject] = [
            "lastMessage" : Message.self
        ]
        return [
            KCS_REFERENCE_MAP_KEY : referenceMap
        ]
    }
    
}
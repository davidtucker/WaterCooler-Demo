//
//  KinveyDataManager.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/4/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

class KinveyDataManager {
    
    init() {
        addObservers()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func addObservers() {
        let mainQueue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: mainQueue) { (notification) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.didReceiveMemoryWarning()
            })
        }
    }
    
    private func didReceiveMemoryWarning() {
        self.imageCache = Dictionary<String,UIImage!>()
    }
    
    //MARK: -
    //MARK: Data
    
    private var threads:[MessageThread]! = nil {
        didSet {
            sortedThreads = sortThreads()
        }
    }
    
    var sortedThreads:[MessageThread]! = nil {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(WaterCoolerConstants.Notifications.MessageThreadsUpdated, object:nil, userInfo:nil)
        }
    }
    
    private var users:[KCSUser]! = nil {
        didSet {
            // Order by First Name & Exclude Current User from List
            sortedUsers = sorted(users, { $0.givenName < $1.givenName }).filter({ $0.userId != KCSUser.activeUser().userId })
        }
    }
    
    var sortedUsers:[KCSUser]! = nil {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(WaterCoolerConstants.Notifications.UsersUpdated, object:nil, userInfo:nil)
        }
    }
    
    var imageCache:[String:UIImage!] = Dictionary<String,UIImage!>()
    
    //MARK: -
    //MARK: Data Stores from Kinvey
    
    lazy var userStore:KCSAppdataStore = {
        let userCollection:KCSCollection = KCSCollection.userCollection()
        let store = KCSAppdataStore(collection: userCollection, options: nil)
        return store
    }()
    
    lazy var threadStore:KCSLinkedAppdataStore = {
        let collection = KCSCollection(fromString: "MessageThreads", ofClass: MessageThread.self)
        let store = KCSLinkedAppdataStore(collection: collection, options: nil)
        return store
    }()
    
    lazy var messagesStore:KCSAppdataStore = {
        let collection = KCSCollection(fromString: "Messages", ofClass: Message.self)
        let store = KCSAppdataStore(collection: collection, options: nil)
        return store
    }()
    
    //MARK: -
    //MARK: Public API
    
    func newMessageReceived(userInfo:[NSObject:AnyObject]?) {
        let message = Message(userInfo: userInfo!)
        let notificationUserInfo:[NSObject:AnyObject]? = [
            WaterCoolerConstants.Notifications.NewMessageReceivedUserInfoMessageKey : message
        ]
        let notification = NSNotification(name: WaterCoolerConstants.Notifications.NewMessageReceived, object: nil, userInfo:notificationUserInfo)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        if let thread = getThreadForEntityId(message.threadId) {
            // Message in Existing Thread, Update Last Message and Re-sort
            thread.lastMessage = message
            sortedThreads = sortThreads()
        } else {
            // New Thread, Let's Just Re-load All of them.  We could certainly
            // reload just the new one as well, but this is the easier approach
            // for this demo app
            fetchMessageThreads()
        }
    }
    
    func invalidateImageCacheForUser(user:KCSUser) {
        imageCache.removeValueForKey(user.userId)
    }
    
    //MARK: -
    //MARK: Private Fetching Methods
    
    private func sortThreads() -> [MessageThread] {
        return sorted(threads, { $0.getIntervalForSort() > $1.getIntervalForSort() })
    }
    
    func fetchMessageThreads() {
        fetchMessageThreads { (results, error) -> () in
            // Do Something
        }
    }
    
    func fetchMessageThreads(completion: ([MessageThread]!, NSError!) -> ()) {
        threadStore.queryWithQuery(KCSQuery(), withCompletionBlock: { (results, error) -> Void in
            if(error != nil) {
                println("ERROR FETCHING THREADS")
                completion(nil, error)
            } else {
                self.threads = results as [MessageThread]
                completion(self.threads, error)
            }
        }, withProgressBlock: nil, cachePolicy: KCSCachePolicyNone)
    }
    
    func fetchUsers() {
        fetchUsers { (results, error) -> () in
            // Do Nothing
        }
    }
    
    func fetchUsers(completion: ([KCSUser]!, NSError!) -> ()) {
        userStore.queryWithQuery(KCSQuery(), withCompletionBlock: { (results, error) -> Void in
            if(error == nil) {
                self.users = results as [KCSUser]
                completion(results as [KCSUser]!, nil)
            } else {
                completion(nil, error)
            }
            
        }, withProgressBlock: nil)
    }
    
    //MARK: -
    //MARK: Utility Methods for Kinvey
    
    func saveMessage(message:Message, thread:MessageThread, completion: (savedMessage:Message) -> ()) {
        /*
        thread.lastMessage = message
        sortedThreads = sortThreads()
        threadStore.saveObject(thread, withCompletionBlock: { (results, error) -> Void in
            completion(savedThread: results[0] as MessageThread)
        }, withProgressBlock: nil)
        */
        messagesStore.saveObject(message, withCompletionBlock: { (results, error) -> Void in
            completion(savedMessage: results[0] as Message)
        }, withProgressBlock: nil)
    }
    
    func messagesForThread(thread:MessageThread, completeion:([Message]) -> ()) {
        let query = KCSQuery(onField: "threadId", withExactMatchForValue: thread.entityId)
        messagesStore.queryWithQuery(query, withCompletionBlock: { (results, error) -> Void in
            completeion(results as [Message])
        }, withProgressBlock: nil)
    }
    
    func getThreadForEntityId(entityId:String) -> MessageThread! {
        return filter(sortedThreads, { $0.entityId == entityId }).first
    }
    
    func getThreadForUser(user:KCSUser, completion:(MessageThread) -> ()) {
        let threadIdentifier = MessageThread.threadIdentifierForUser(user)
        var targetThread:MessageThread! = nil
        if let thread = getThreadForEntityId(threadIdentifier) {
            completion(thread)
        } else {
            newThreadForUser(user, { (result) -> () in
                completion(result)
            })
        }
    }
    
    private func newThreadForUser(user:KCSUser,completion:(MessageThread) -> ()) {
        let thread:MessageThread = MessageThread(user: user)
        threadStore.saveObject(thread, withCompletionBlock: { (results, error) -> Void in
            self.fetchMessageThreads({ (results, error) -> () in
                completion(thread)
            })
        }, withProgressBlock: nil)
    }
    
    func fetchUserFromThread(thread:MessageThread) -> KCSUser! {
        let userIdToFetch = fetchUserIdFromThread(thread)
        return filter(users, { $0.userId == userIdToFetch }).first
    }
    
    func fetchUserIdFromThread(thread:MessageThread) -> String {
        let currentUserId = KCSUser.activeUser().userId
        let userIds:[String]! = thread.entityId.componentsSeparatedByString(":")
        return (currentUserId == userIds[0]) ? userIds[1] : userIds[0]
    }
    
}
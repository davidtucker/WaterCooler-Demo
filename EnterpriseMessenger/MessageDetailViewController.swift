//
//  MessageDetailView.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/23/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class MessageDetailViewController : SLKTextViewController {
    
    private var sortedMessages:[Message]!
    
    private var isLoadingInitialData:Bool = false
    
    lazy var dataManager:KinveyDataManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.dataManager
    }()
    
    var thread:MessageThread! = nil {
        didSet {
            isLoadingInitialData = true
            let user = dataManager.fetchUserFromThread(thread)
            navigationItem.title = user.givenName + " " + user.surname
            self.dataManager.messagesForThread(thread, completeion: { (messages) -> () in
                self.isLoadingInitialData = false
                self.updateMessages(messages)
            })
        }
    }
    
    func updateMessages(messages:[Message]) {
        var threadMessages = messages
        self.sortedMessages = sorted(messages, {
            $0.getDateForSort().timeIntervalSinceNow < $1.getDateForSort().timeIntervalSinceNow
        }).reverse()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.scrollToBottom(false)
        })
    }
    
    func messageReceived(notification:NSNotification) {
        if (isLoadingInitialData) {
            return
        }
        if let info = notification.userInfo as? Dictionary<String,AnyObject> {
            let message:Message = info[WaterCoolerConstants.Notifications.NewMessageReceivedUserInfoMessageKey] as Message
            if(message.threadId == thread.entityId) {
                addMessage(message)
            }
        }
    }
    
    private func scrollToBottom(isAnimated:Bool) {
        if(sortedMessages == nil || sortedMessages.isEmpty) {
            return
        }
        let indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: isAnimated)
    }
    

    override class func tableViewStyleForCoder(decoder:NSCoder) -> UITableViewStyle {
        return UITableViewStyle.Plain
    }
    
    override func viewDidLoad() {
        tableView.registerClass(MessageTableViewSenderCell.self, forCellReuseIdentifier: "SenderCell")
        tableView.registerClass(MessageTableViewRecipientCell.self, forCellReuseIdentifier: "RecipientCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75.0
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.allowsSelection = false
        keyboardPanningEnabled = true
        inverted = true
        shouldScrollToBottomAfterKeyboardShows = true
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"messageReceived:", name: WaterCoolerConstants.Notifications.NewMessageReceived, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let type:Int = Int(arc4random_uniform(2))
        
        let message = sortedMessages[indexPath.row]
        if(message.senderId == KCSUser.activeUser().userId) {
            let cell = tableView.dequeueReusableCellWithIdentifier("SenderCell") as MessageTableViewSenderCell
            cell.messageContent = message.messageText
            cell.transform = tableView.transform
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipientCell") as MessageTableViewRecipientCell
        cell.messageContent = message.messageText
        cell.transform = tableView.transform
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return thread.messages.count
        if(sortedMessages == nil) {
            return 0
        }
        return sortedMessages.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func didCommitTextEditing(sender: AnyObject!) {
        super.didCommitTextEditing(sender)
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        self.textView.resignFirstResponder()

        let message = Message(messageText: textView.text, recipientId: dataManager.fetchUserIdFromThread(thread))
        message.threadId = thread.entityId
        message.userEntryTime = NSDate()
        addMessage(message)
        
        // This will get set on the server, but we'll go ahead and fetch it here to
        // ensure the threads view is up to date
        thread.lastMessage = message
        
        dataManager.saveMessage(message, thread: thread) { (savedMessage) -> () in
            // Complete
        }
        
        super.didPressRightButton(sender)
    }
    
    private func addMessage(message:Message) {
        let indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let rowAnimation = UITableViewRowAnimation.Bottom
        let scrollPosition = UITableViewScrollPosition.Bottom
        
        tableView.beginUpdates()
        sortedMessages.insert(message, atIndex: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation:rowAnimation)
        tableView.endUpdates()
        
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
    }
    
}
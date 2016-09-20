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
    
    private var sections:[MessageSection] = []
    
    private var isLoadingInitialData:Bool = false
    
    lazy var dataManager:KinveyDataManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
        self.sortedMessages = Array(messages.sort({
            $0.getDateForSort().timeIntervalSinceNow < $1.getDateForSort().timeIntervalSinceNow
        }).reverse())
        
        updateSections()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.scrollToBottom(false)
        })
    }
    
    func updateSections() {
        sections = []
        var currentSection:MessageSection? = nil
        var previousMessage:Message? = nil
        for message in sortedMessages {
            if shouldMessageBeInNewSection(message, previousMessage: previousMessage) {
                currentSection = MessageSection()
                sections.append(currentSection!)
            }
            currentSection!.addMessage(message)
            previousMessage = message
        }
    }
    
    func shouldMessageBeInNewSection(message:Message, previousMessage:Message?) -> Bool {
        if(previousMessage == nil) {
            return true
        }
        
        let timeA = message.getDateForSort().timeIntervalSince1970
        let timeB = previousMessage!.getDateForSort().timeIntervalSince1970
        if(abs(timeA - timeB) > WaterCoolerConstants.Message.MaximumSectionTimeVariance) {
            return true
        }
        
        return false
    }
    
    func messageReceived(notification:NSNotification) {
        if (isLoadingInitialData) {
            return
        }
        if let info = notification.userInfo as? Dictionary<String,AnyObject> {
            let message:Message = info[WaterCoolerConstants.Notifications.NewMessageReceivedUserInfoMessageKey] as! Message
            if(message.threadId == thread.entityId) {
                addMessage(message)
            }
        }
    }
    
    @IBAction func closePopup(sender:AnyObject) {
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
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
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Footer")
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
        let section = sections[indexPath.section]
        let message = section.messages[indexPath.row]
        if(message.senderId == KCSUser.activeUser().userId) {
            let cell = tableView.dequeueReusableCellWithIdentifier("SenderCell") as! MessageTableViewSenderCell
            cell.messageContent = message.messageText
            cell.transform = tableView.transform
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipientCell") as! MessageTableViewRecipientCell
        cell.user = dataManager.fetchUserFromThread(thread)
        cell.messageContent = message.messageText
        cell.transform = tableView.transform
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let firstMessage = sections[section].messages[0]
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor.lightGrayColor()
        header.textLabel!.text = InterfaceConfiguration.formattedDate(DateFormat.Long, date: firstMessage.getDateForSort())
        header.textLabel!.textAlignment = NSTextAlignment.Center
        header.textLabel!.font = InterfaceConfiguration.smallDetailFont
        header.tintColor = UIColor.whiteColor()
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let h = tableView.dequeueReusableHeaderFooterViewWithIdentifier("Footer")! as UITableViewHeaderFooterView
        h.transform = tableView.transform
        return h
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].messages.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
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
        let rowAnimation = UITableViewRowAnimation.Bottom
        let scrollPosition = UITableViewScrollPosition.Bottom
        let indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        tableView.beginUpdates()
        
        sortedMessages.insert(message, atIndex: 0)
        updateSections()
        
        if(sortedMessages.count == 1 || shouldMessageBeInNewSection(message, previousMessage: sortedMessages[1])) {
            let sectionSet = NSIndexSet(index: 0)
            tableView.insertSections(sectionSet, withRowAnimation: UITableViewRowAnimation.Bottom)
        } else {
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation:rowAnimation)
        }
        
        tableView.endUpdates()
        
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
    }
    
}

private class MessageSection {
    
    var messages:[Message] = []
    
    func addMessage(message:Message) {
        messages.append(message)
    }
    
}
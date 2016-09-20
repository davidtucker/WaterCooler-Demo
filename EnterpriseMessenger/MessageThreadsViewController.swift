//
//  MessagesViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/19/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

class MessageThreadsViewController : UITableViewController, DirectoryTableViewControllerDelegate {
    
    //MARK: -
    //MARK: Private Variables
    
    private var selectedThread:MessageThread! = nil
    
    private lazy var dataManager:KinveyDataManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.dataManager
    }()
    
    private lazy var addButton:UIBarButtonItem = {
        let button:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addMessageThread:")
        button.tintColor = UIColor.whiteColor()
        return button
    }()
    
    //MARK: -
    //MARK: View Related Actions
    
    func setMessageTarget(thread:MessageThread) {
        navigateToThreadDetail(thread)
    }
    
    func navigateToThreadDetail(thread:MessageThread) {
        selectedThread = thread
        performSegueWithIdentifier("ShowThreadDetail", sender: self)
    }
    
    func addMessageThread(id:AnyObject) {
        let modalUserSelector = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ModalUserSelector") as! UINavigationController
        let directory = modalUserSelector.topViewController as! DirectoryTableViewController
        directory.directoryMode = DirectoryMode.NewConversation
        directory.directoryDelegate = self
        presentViewController(modalUserSelector, animated: true, completion: nil)
    }
    
    //MARK: -
    //MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(MessageThreadTableViewCell.self, forCellReuseIdentifier: "MessageThreadCell")
        self.parentViewController?.navigationItem.setRightBarButtonItem(addButton, animated: true)
        self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 48.0, 0.0)
        self.tableView.contentOffset = CGPointMake(0, 44.0)
        let hud = presentIndeterminiteMessage("Loading")
        dataManager.fetchUsers { (users, error) -> () in
            self.dataManager.fetchMessageThreads()
            hud.hide(true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        let mainQueue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserverForName(WaterCoolerConstants.Notifications.MessageThreadsUpdated, object: nil, queue: mainQueue) { (notification) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: -
    //MARK: UITableViewDataSource Implementation
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(dataManager.sortedThreads == nil) {
            return 0
        }
        return dataManager.sortedThreads.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let thread = dataManager.sortedThreads[indexPath.row]
        var height:CGFloat = CGFloat(66.0)
        if(thread.lastMessage != nil) {
            height = MessageThreadTableViewCell.heightForMessageText(thread.lastMessage.messageText, width: self.tableView.frame.width)
        }
        return height
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:MessageThreadTableViewCell = tableView.dequeueReusableCellWithIdentifier("MessageThreadCell") as! MessageThreadTableViewCell;
       cell.thread = dataManager.sortedThreads[indexPath.row]
        return cell;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    //MARK: -
    //MARK: UITableViewDelegate Implementation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigateToThreadDetail(dataManager.sortedThreads[indexPath.row])
    }
    
    //MARK: -
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationController = segue.destinationViewController as! MessageDetailViewController
        if(selectedThread != nil) {
            destinationController.thread = selectedThread
        }
    }

}
//
//  DirectoryDetailViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/28/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

class DirectoryDetailViewController : UserDetailBaseViewController {
    
    var user:KCSUser? = nil {
        didSet {
            profileView.user = user
            navigationItem.title = user!.givenName + " " + user!.surname
        }
    }
    
    override func profileMode() -> ProfileMode {
        return ProfileMode.DirectoryDetail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0, 0, 0);
    }
    
    //MARK: --
    //MARK: ProfileViewDelegate Implementation
    
    func messageUser(user: KCSUser) {
        performSegueWithIdentifier(WaterCoolerConstants.Segue.MessagesFromDirectory, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let messagesNavController = segue.destinationViewController as UINavigationController
        let messagesModalController = messagesNavController.viewControllers[0] as MessageDetailViewController
        dataManager.getThreadForUser(user!, completion: { (thread) -> () in
            messagesModalController.thread = thread
        })
    }
}
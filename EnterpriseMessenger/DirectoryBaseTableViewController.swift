//
//  DirectoryBaseTableViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/9/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

class DirectoryBaseTableViewController : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        tableView.rowHeight = 68.0
        tableView.registerClass(DirectoryTableViewCell.self, forCellReuseIdentifier: "DirectoryCell")
        //loadUsers()
    }
    
}
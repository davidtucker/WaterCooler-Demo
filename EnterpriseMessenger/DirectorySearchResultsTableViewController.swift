//
//  DirectorySearchResultsTableViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/9/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

class DirectorySearchResultsTableViewController : DirectoryBaseTableViewController {
    
    var filteredUsers:[KCSUser]! = [KCSUser]()
    
    // MARK: -
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:DirectoryTableViewCell! = tableView.dequeueReusableCellWithIdentifier("DirectoryCell") as! DirectoryTableViewCell;
        cell.user = filteredUsers[indexPath.row]
        return cell
    }
    
}
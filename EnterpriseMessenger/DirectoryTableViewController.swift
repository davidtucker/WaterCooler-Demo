//
//  DirectoryTableViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/21/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

protocol DirectoryTableViewControllerDelegate {
    
    func setMessageTarget(thread:MessageThread)
    
}

class DirectoryTableViewController : DirectoryBaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    lazy var dataManager:KinveyDataManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.dataManager
    }()
    
    var directoryDelegate:DirectoryTableViewControllerDelegate?
    
    lazy var cancelButton:UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelDirectorySearch:")
        return button
    }()
    
    lazy var searchController: UISearchController = {
        let searchController:UISearchController = UISearchController(searchResultsController: self.resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = true
        return searchController
    }()
    
    lazy var resultsTableController: DirectorySearchResultsTableViewController = {
        let resultsTableController = DirectorySearchResultsTableViewController()
        resultsTableController.tableView.delegate = self
        return resultsTableController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationItem.setLeftBarButtonItem(cancelButton, animated: false)
        self.tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        dataManager.fetchUsers()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(dataManager.sortedUsers == nil) {
            return 0
        }
        return dataManager.sortedUsers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:DirectoryTableViewCell! = tableView.dequeueReusableCellWithIdentifier("DirectoryCell") as DirectoryTableViewCell;
        let user:KCSUser! = dataManager.sortedUsers[indexPath.row];
        cell.user = user
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func cancelDirectorySearch(sender:AnyObject!) {
        self.dismissViewControllerAnimated(true) {
            self.directoryDelegate = nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedRow = tableView.indexPathForSelectedRow()?.row
        let selectedUser:KCSUser! = dataManager.sortedUsers[selectedRow!]

        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = MBProgressHUDModeIndeterminate
        hud.labelText = "Creating Conversation"
        hud.dimBackground = true
        
        dataManager.getThreadForUser(selectedUser, completion: { (thread) -> () in
            hud.hide(true)
            self.directoryDelegate!.setMessageTarget(thread)
            self.dismissViewControllerAnimated(true) {
                self.directoryDelegate = nil
            }
        })
        
    }
    
    //MARK: -
    //MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchResults = dataManager.sortedUsers
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        let searchItems = strippedString.componentsSeparatedByString(" ") as [String]
        
        var andMatchPredicates = [NSPredicate]()
        
        for searchString in searchItems {

            var searchItemsPredicate = [NSPredicate]()
            searchItemsPredicate.append(predicateForField("title", searchTerm:searchString))
            searchItemsPredicate.append(predicateForField("givenName", searchTerm:searchString))
            searchItemsPredicate.append(predicateForField("surname", searchTerm:searchString))
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicates = NSCompoundPredicate.orPredicateWithSubpredicates(searchItemsPredicate)
            andMatchPredicates.append(orMatchPredicates)
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate.andPredicateWithSubpredicates(andMatchPredicates)
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluateWithObject($0) }
        
        // Hand over the filtered results to our search results table.
        resultsTableController.filteredUsers = filteredResults
        resultsTableController.tableView.reloadData()
    }
    
    private func predicateForField(fieldName:String, searchTerm:String) -> NSPredicate {
        var lhs = NSExpression(forKeyPath: fieldName)
        var rhs = NSExpression(forConstantValue: searchTerm)
        return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
    }
    
}
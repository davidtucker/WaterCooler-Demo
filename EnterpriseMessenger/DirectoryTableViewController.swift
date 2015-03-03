//
//  DirectoryTableViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/21/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

enum DirectoryMode {
    case NewConversation
    case DirectoryDetail
}

protocol DirectoryTableViewControllerDelegate {
    
    func setMessageTarget(thread:MessageThread)
    
}

class DirectoryTableViewController : DirectoryBaseTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var directoryMode:DirectoryMode = DirectoryMode.DirectoryDetail
    
    var isReappearing:Bool = false

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
    
    var selectedUser:KCSUser! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad();
        if(directoryMode == .DirectoryDetail) {
            self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 46.0, 0.0)
            self.tableView.contentOffset = CGPointMake(0, -20.0)
        }
        searchController.searchBar.barTintColor = UIColor(red: 0.953, green: 0.953, blue: 0.953, alpha: 1.0)
        searchController.searchBar.placeholder = "Search Users"
        self.navigationItem.setLeftBarButtonItem(cancelButton, animated: false)
        self.tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        dataManager.fetchUsers()
    }
    
    override func viewWillAppear(animated: Bool) {
        if(directoryMode == .DirectoryDetail && isReappearing) {
            self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 46.0, 0.0)
            self.tableView.contentOffset = CGPointMake(0, 44.0)
        }
        if let indexPath = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        isReappearing = true
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
        
        let selectedRow = indexPath.row
        
        if(tableView == self.tableView) {
            selectedUser = dataManager.sortedUsers[selectedRow]
        } else {
            selectedUser = resultsTableController.filteredUsers[selectedRow]
        }
        
        if(directoryMode == DirectoryMode.NewConversation) {
            let hud = presentIndeterminiteMessage("Loading Conversation")
            dataManager.getThreadForUser(selectedUser, completion: { (thread) -> () in
                hud.hide(true)
                self.directoryDelegate!.setMessageTarget(thread)
                self.dismissViewControllerAnimated(true) {
                    self.directoryDelegate = nil
                }
            })
        } else {
            if(tableView != self.tableView) {
                self.resultsTableController.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.performSegueWithIdentifier(WaterCoolerConstants.Segue.ShowDirectoryDetail, sender: self)
                })
            } else {
                performSegueWithIdentifier(WaterCoolerConstants.Segue.ShowDirectoryDetail, sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.searchController.searchBar.text = ""
        let destinationViewController = segue.destinationViewController as DirectoryDetailViewController
        destinationViewController.user = selectedUser
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
//
//  WCSearchTableViewController.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/5/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import UIKit

class WCSearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var filteredTableData = [NSDictionary]()
    var dataSource = [NSDictionary]()
    private var resultSearchController = UISearchController()
    private var filtersList = [Filter]()
    private var selectedLimit: Int = 10
    var coreData: WCCoreData!
    
    var wikiSearch = WCWikipediaAPI() {
        willSet {
            self.wikiSearch.cancel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coreData = WCCoreData(context: (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext)
        self.title = "Search Wiki"
        self.resultSearchController = ({
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.delegate = self
            searchController.searchResultsUpdater = self
            searchController.searchBar.showsSearchResultsButton = true
            searchController.dimsBackgroundDuringPresentation = false
            searchController.active = true
            searchController.searchBar.placeholder = "Enter text to search wiki"
            searchController.searchBar.becomeFirstResponder()
            searchController.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = searchController.searchBar
            return searchController
        })()
    }


    // MARK: - Table view dataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        if (self.resultSearchController.active) {
            numberOfRows = self.dataSource.count
        }
        
        return numberOfRows
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let searchWikiCell = tableView.dequeueReusableCellWithIdentifier("searchWikiCellIdentifier", forIndexPath: indexPath)
        
        if (self.resultSearchController.active) {
            searchWikiCell.textLabel?.text = self.dataSource[indexPath.row]["title"] as? String
            searchWikiCell.detailTextLabel?.text = "Last Edited:" + self.prettyDateFromString(self.dataSource[indexPath.row]["timestamp"] as! String)
        }
        
        return searchWikiCell
    }
    
    
    // MARK: - SearchResultsUpdating delegate
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard searchController.searchBar.text?.characters.count > 0 else {
            return
        }
        
        self.filteredTableData.removeAll(keepCapacity: false)
        self.searchWiki(searchController.searchBar.text!, limit: self.selectedLimit)
    }
    
    
    // MARK: - SearchBar delegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.clearDataSource()
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            self.clearDataSource()
        }
    }
    
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        // To present a controller which will display the 
        // count of the results to be displayed
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultsController = storyboard.instantiateViewControllerWithIdentifier("WCResultsCountViewController") as! WCResultsCountViewController
        resultsController.modalPresentationStyle = .Popover
        resultsController.preferredContentSize = CGSizeMake(300, 3 * 44.0)
        resultsController.dataSource = ["10", "20", "30"]
        resultsController.selectedCount = String(self.selectedLimit)
        resultsController.didSelectCell = {(iValue: String) -> Void in
            self.selectedLimit = Int(iValue)!
        }
        
        let popoverPresentationController = resultsController.popoverPresentationController
        popoverPresentationController?.sourceView = searchBar
        popoverPresentationController?.sourceRect = searchBar.frame
        popoverPresentationController?.permittedArrowDirections = .Any
        
        if (self.presentedViewController != nil) {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.presentViewController(resultsController, animated: true, completion: nil)
            })
        } else {
            self.presentViewController(resultsController, animated: true, completion: nil)
        }
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailSegue" && self.dataSource.count > 0 {
            let controller = segue.destinationViewController as! WCDetailViewController
            
            if let indexPath: NSIndexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                controller.detailItem = self.dataSource[indexPath.row]["title"]
            }
            
            if (self.resultSearchController.active) {
                self.resultSearchController.active = false
            }
        }
    }
    
    
    // MARK: - User Defined
    
    /* Used for searching the entered text using wikipedia API */
    func searchWiki(searchString: String, limit: Int) {
        // Do an online search only when network is not connected
        // and there are no existing results for the searched string
        if WCReachability.isConnectedToNetwork() && !self.cachedRecordExists(searchString).result {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.wikiSearch = WCWikipediaAPI(text: searchString)
            dispatch_async(dispatch_get_global_queue(Int(0), UInt(0))) {
                var result: [AnyObject] = []
                do {
                    result = try self.wikiSearch.wait()
                } catch Error.Cancelled {} // Ignore cancellation
                  catch { self.handleWikiFetchFailError("Error fetching response, please try again.") }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.filteredTableData = result as! [NSDictionary]
                    self.setResultDataSource()
                    self.tableView.reloadData()
                })
                
                self.saveSearchResults(searchString)
            }
        } else {
            self.fetchCachedRecords(searchString)
        }
    }
    
    
    /* To check if there are existing records and if yes
       return those results */
    func cachedRecordExists(searchText: String) -> (result: Bool, records: NSArray) {
        var result: Bool = false
        var records: NSArray = []
        self.filtersList = self.coreData.fetchFilters()
        guard self.filtersList.filter({$0.searchString == searchText}).count > 0 else {
            return (result, records)
        }
        
        records = self.coreData.fetchWiki(searchText)
        if records.count > 0 {
            result = true
        }
        
        return (result, records)
    }
    
    
    /* To fetch existing records during search */
    func fetchCachedRecords(searchText: String) {
        let returnValue = self.cachedRecordExists(searchText)
        if returnValue.result {
            self.filteredTableData.removeAll(keepCapacity: false)
            for wikiData in returnValue.records as! [Wiki] {
                self.filteredTableData.append(wikiData.toDict())
            }
            
            self.setResultDataSource()
            self.tableView.reloadData()
        }
    }
    
    
    /* To persist the searched results to coreData */
    func saveSearchResults(searchText: String) {
        self.filtersList = self.coreData.fetchFilters()
        guard self.filtersList.filter({$0.searchString == searchText}).count == 0 else {
            return
        }
        
        let filter = self.coreData.addNewFilter(searchText)
        for wikiData in self.filteredTableData {
            self.coreData.addWikiData(wikiData, filter: filter)
        }
        
        self.coreData.save()
    }
    
    
    /* To convert date returned from search API into a
       more understandable format */
    func prettyDateFromString(dateString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.dateFromString(dateString)
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateStyle = .ShortStyle;
        dateFormatter.timeStyle = .ShortStyle;
        
        return dateFormatter.stringFromDate(date!)
    }
    
    
    /* To filter empty values returned by search API */
    func filterEmptyData(data: NSArray) -> NSArray {
        let resultPredicate = NSPredicate(format: "title.length > 0 && timestamp.length > 0", argumentArray: nil)
        return data.filteredArrayUsingPredicate(resultPredicate)
    }
    
    
    /* To set tableView datasource */
    func setResultDataSource() {
        if self.filteredTableData.count > self.selectedLimit {
            self.dataSource = Array(self.filteredTableData[0..<self.selectedLimit])
        } else {
            self.dataSource = self.filteredTableData
        }
    }
    
    
    /* To clear dataSource of tableView */
    func clearDataSource() {
        self.dataSource.removeAll(keepCapacity: false)
        self.tableView.reloadData()
    }
    
    
    /* To handle error which can happen during search and
    display an alertView */
    func handleWikiFetchFailError(errorString: String) {
        if (self.presentedViewController != nil) {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.showAlert(errorString)
            })
        } else {
            self.showAlert(errorString)
        }
    }
    
    
    /* Show alert view*/
    func showAlert(errorString: String) {
        let alertController: UIAlertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
        }
        alertController.addAction(cancelAction)
        
        //Present the AlertController
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}

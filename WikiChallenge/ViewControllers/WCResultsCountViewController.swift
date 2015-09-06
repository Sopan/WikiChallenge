//
//  WCResultsCountViewController.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/6/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import UIKit

class WCResultsCountViewController: UIViewController {
    
    var dataSource: NSArray!
    var selectedCount: String!
    var didSelectCell: ((String) -> Void)?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Result Count"
    }
    
    
    // MARK: - Table view dataSource
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let countCell = tableView.dequeueReusableCellWithIdentifier("resultsCountCellIdentifier", forIndexPath: indexPath)
        countCell.textLabel!.text = self.dataSource[indexPath.row] as? String
        if self.selectedCount == self.dataSource[indexPath.row] as! String {
            countCell.accessoryType = .Checkmark
        }
        return countCell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        self.selectedCount = self.dataSource[indexPath.row] as! String
        if self.didSelectCell != nil {
            self.didSelectCell!(self.selectedCount)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

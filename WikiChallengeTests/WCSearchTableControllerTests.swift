//
//  WCSearchTableControllerTests.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/5/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import XCTest
@testable import WikiChallenge

class WCSearchTableControllerTests: XCTestCase {
    
    var searchController: WCSearchTableViewController!

    override func setUp() {
        super.setUp()
        searchController = WCSearchTableViewController()
        searchController.coreData = WCCoreData(context: setUpInMemoryManagedObjectContext())
    }
    
    
    func testSaveSearchResults() {
        searchController.filteredTableData = [["title": "Wikipedia", "timestamp": "2010-10-09T21:25:50Z"]]
        self.searchController.saveSearchResults("name")
        let wikiList = searchController.coreData.fetchWiki("name")
        XCTAssert(wikiList.count == 1, "Check the new wiki list count matches")
    }
    
    func testFetchCachedResults() {
        let filter = searchController.coreData.addNewFilter("name")
        searchController.coreData.addNewWikiEntry("name", timestamp: "", filterData: filter)
        searchController.fetchCachedRecords("name")
        XCTAssert(searchController.filteredTableData.count == 1, "Check the data source count matches")
    }
    
    func testPrettyDateFromString() {
        let dateString = searchController.prettyDateFromString("2015-08-17T20:04:21Z")
        XCTAssertEqual(dateString, "8/17/15, 1:04 PM", "date string should match")
    }
    
    func testFilterEmptyData() {
        let dataSource = [["title": "Wikipedia", "timestamp": "2010-10-09T21:25:50Z"], ["title": "", "timestamp": "2010-10-09T21:25:50Z"]]
        let verifiedDataSource = searchController.filterEmptyData(dataSource)
        XCTAssertEqual(verifiedDataSource.count, 1, "only valid values should enter")
    }
}

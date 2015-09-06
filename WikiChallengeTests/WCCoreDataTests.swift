//
//  WCCoreDataTests.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/5/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import XCTest
@testable import WikiChallenge

class WCCoreDataTests: XCTestCase {
    
    var coreData: WCCoreData!

    override func setUp() {
        coreData = WCCoreData(context: setUpInMemoryManagedObjectContext())
    }
    
    func testAddFilter() {
        let filter = coreData.addNewFilter("name")
        XCTAssert(filter.searchString == "name", "Check the new person object has the correct name")
    }
    
    func testAddWiki() {
        let filter = coreData.addNewFilter("name")
        let wiki = coreData.addNewWikiEntry("name", timestamp: "2010-10-09T21:25:50Z", filterData: filter)
        XCTAssert(wiki.title == "name", "Check the new wiki object has the correct title")
    }
    
    func testFetchFilter() {
        _ = coreData.addNewFilter("name")
        let filterList = coreData.fetchFilters()
        XCTAssert(filterList.count == 1, "Check the new filter list is correct")
    }
    
    func testFetchWiki() {
        let filter = coreData.addNewFilter("name")
        _ = coreData.addNewWikiEntry("name", timestamp: "2010-10-09T21:25:50Z", filterData: filter)
        let wikiList = coreData.fetchWiki("name")
        XCTAssert(wikiList.count == 1, "Check the new wiki list count matches")
    }
    
    func testAddWikiData() {
        let filter = coreData.addNewFilter("name")
        coreData.addWikiData(["title": "Wikipedia", "timestamp": "2010-10-09T21:25:50Z"], filter: filter)
        let wikiList = coreData.fetchWiki("name")
        XCTAssert(wikiList.count == 1, "Check the new wiki list count matches")
    }
}

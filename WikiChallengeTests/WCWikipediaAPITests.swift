//
//  WCWikipediaAPITests.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/5/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import XCTest
@testable import WikiChallenge

class WCWikipediaAPITests: XCTestCase {
    
    func testSearchDataTask() {
        _ = WCWikipediaAPI(text: "name")
        let URL = NSURL(string: "https://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=name&srnamespace=4&srwhat=text&srprop=timestamp&srlimit=30")!
        let expectation = expectationWithDescription("GET \(URL)")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(URL) { data, response, error in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")
            
            if let HTTPResponse = response as? NSHTTPURLResponse,
                responseURL = HTTPResponse.URL
            {
                XCTAssertEqual(responseURL.absoluteString, URL.absoluteString, "HTTP response URL should be equal to original URL")
                XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
            } else {
                XCTFail("Response was not NSHTTPURLResponse")
            }
            
            expectation.fulfill()
        }
        
        task.resume()
        
        waitForExpectationsWithTimeout(task.originalRequest!.timeoutInterval) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            task.cancel()
        }
    }
    
    
    func testSearchURLForString() {
        let searchAPI = WCWikipediaAPI(text: "name")
        let url = searchAPI.searchURLForString("name")
        XCTAssertEqual(url.query, "action=query&list=search&format=json&srsearch=name&srnamespace=4&srwhat=text&srprop=timestamp&srlimit=30")
    }
}

//
//  WCWikipediaAPI.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/5/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import UIKit

enum Error : ErrorType {
    case BadResponse(NSURLResponse?)
    case HTTPFailure(NSHTTPURLResponse)
    case NoData
    case Cancelled
    case Unknown
}


class WCWikipediaAPI {
    
    var searchText: String
    private var sessionTask: NSURLSessionDataTask?
    private var resultGroup: dispatch_group_t
    private var responseData: NSData?
    
    convenience init() { self.init(text: "") }
    
    init(text: String) {
        self.searchText = text
        self.resultGroup = dispatch_group_create()
        guard text != "" else { return }
        
        dispatch_group_enter(self.resultGroup)
        let url = self.searchURLForString(self.searchText)
        
        // This is a retain loop, but the task will release this closure after it fires.
        self.sessionTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, _, _) in
            self.responseData = data
            dispatch_group_leave(self.resultGroup)
        })
        precondition(self.sessionTask != nil, "Could not create task")
        self.sessionTask?.resume()
    }
    
    
    func wait() throws -> [AnyObject] {
        // Could put a timeout here in general, but NSURLSession already gives us that
        dispatch_group_wait(self.resultGroup, DISPATCH_TIME_FOREVER)
        
        if let error = self.sessionTask?.error {
            if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                throw Error.Cancelled
            } else {
                throw error
            }
        }
        
        guard let response = self.sessionTask?.response as? NSHTTPURLResponse else {
            throw Error.BadResponse(self.sessionTask?.response)
        }
        
        guard 200..<300 ~= response.statusCode else {
            throw Error.HTTPFailure(response)
        }
        
        guard let resultData = self.responseData else {
            throw Error.NoData
        }
        
        return parseResponse(resultData)
    }
    
    
    func cancel() {
        self.sessionTask?.cancel()
    }
    
    
    /* Parse the results of wiki search call */
    func parseResponse(data: NSData) -> [AnyObject] {
        var aResultString: NSDictionary = [:]
        do {
            aResultString = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            guard (aResultString["query"] != nil) else {
                return []
            }
            
            let aQueryData: NSDictionary = aResultString["query"]! as! NSDictionary
            guard aQueryData["search"]?.count > 0 else {
                return []
            }
            return aQueryData["search"] as! [AnyObject]
        } catch let error as NSError {
            print("Error while parsing \(error), \(error.userInfo)")
            return []
        } catch {
            print("Bad response")
            return []
        }
    }
    
    
    /* Get the search URL by adding searchText and
       limit of results */
    func searchURLForString(text: String) -> NSURL {
        var aRequestURL: NSURL = NSURL(string: "")!
        if let urlString = self.searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            aRequestURL = NSURL(string: "https://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=\(urlString)&srnamespace=4&srwhat=text&srprop=timestamp&srlimit=30")!
        }
        
        print("Request URL \(aRequestURL)")
        return aRequestURL
    }
}

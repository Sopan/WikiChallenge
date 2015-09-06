//
//  WCDetailViewController.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/5/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import UIKit
import WebKit

class WCDetailViewController: UIViewController, WKNavigationDelegate {
   
    @IBOutlet var progressView: UIProgressView!
    var webView: WKWebView!
    var detailItem: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SSOverlayView.showLoadingOverlayOnView(self.view)
        self.webView = WKWebView()
        self.webView.navigationDelegate = self
        self.view.insertSubview(self.webView, belowSubview: progressView)
        let urlString: String = "https://www.wikipedia.org/wiki/" + (self.detailItem as! String)
        let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        self.webView!.loadRequest(NSURLRequest(URL:url!))
        self.webView.allowsBackForwardNavigationGestures = true
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        self.view.addConstraints([height, width])
        
        // Add ourselves as observer
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            self.progressView.hidden = (self.webView.estimatedProgress == 1)
            self.progressView.progress = Float(self.webView.estimatedProgress)
        }
    }
    
    
     // MARK: - Navigation delegates
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        title = webView.title
        SSOverlayView.hideLoadingOverlayFromView(self.view)
    }
    
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        SSOverlayView.hideLoadingOverlayFromView(self.view)
        self.handleWikiFetchFailError(error.localizedDescription)
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
    
    
    deinit {
        // Remove observer
        self.webView?.removeObserver(self, forKeyPath:"estimatedProgress");
    }
}

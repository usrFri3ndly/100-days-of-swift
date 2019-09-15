//
//  ViewController.swift
//  project4
//
//  Created by Sc0tt on 14/09/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    // create web and progress views
    @IBOutlet var webView: WKWebView!
    var selectedWebsite: String?
    var progressView: UIProgressView!
    
    // array of authorised websites
    var websites = ["hackingwithswift.com", "raywenderlich.com", "swiftbysundell.com", "useyourloaf.com", "udemy.com"]
    
    // create instance of class and make webview the view for view controller
    override func loadView() {
        webView = WKWebView ()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // open button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        // progress bar to fit contents
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        // wrap into button to allow placement on toolbar
        let progressButton = UIBarButtonItem(customView: progressView)
        
        // Tool bar items
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let back = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector(goBack))
        let forward = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector(goForward))
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        // Tool bar array
        toolbarItems = [progressButton, spacer, back, forward, spacer, refresh]
        navigationController?.isToolbarHidden = false
        
        // KVO - observe page load time
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        // store location of url
        let url = URL(string: "https://www." + selectedWebsite!)!
        // url request
        webView.load(URLRequest(url: url))
        // allow navigation
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // naivgate back if possible
    @objc func goBack() {
        if webView.canGoBack
        {
            webView.goBack()
        }
    }
    
    // navigate forward if possible
    @objc func goForward() {
        if webView.canGoForward
        {
            webView.goForward()
        }
    }

    // open button method
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open Page", message: nil, preferredStyle: .actionSheet)
        // create action for each website in array
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    // take action/url and load into webview
    func openPage(action: UIAlertAction) {
        let url = URL(string: "https://www." + action.title!)!
        webView.load(URLRequest(url: url))
    }
    
    // when page has loaded
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    // pass value to progress view
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // restrictions only allow websites in array to load
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        // block websites that aren't in website array
        // exclude about:blank
        if url!.absoluteString != "about:blank" {
            let ac = UIAlertController(title: "⛔️ Unauthorised Access", message: "Access to \(url!) is restricted.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Return", style: .default, handler: nil))
            present(ac, animated: true)
        }
        decisionHandler(.cancel)
    }
}


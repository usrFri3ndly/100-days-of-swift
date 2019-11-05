//
//  WebViewController.swift
//  project16
//
//  Created by Sc0tt on 05/11/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var item: Capital?
    
    override func loadView() {
        // create webView
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // check for item
        guard let item = item else { return }

        // load wiki url for selected capital
        let url = URL(string: item.wiki)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
    }
    

}

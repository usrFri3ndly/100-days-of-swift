//
//  DetailViewController.swift
//  project7
//
//  Created by Sc0tt on 29/09/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView () {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // check item had been returned
        guard let detailItem = detailItem else { return }
        
        // custom html/css string to define how content should be displayed
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
            <style> body { font-size: 150%;} </style>
        </head>
        <body>
            \(detailItem.body)
        </body>
        </html>
        """
        
        // load the custom html strin
        webView.loadHTMLString(html, baseURL: nil)
    }
    


}

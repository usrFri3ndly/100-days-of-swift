//
//  tableViewController.swift
//  project4
//
//  Created by Sc0tt on 15/09/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit

class tableViewController: UITableViewController {
    
    // array of websites
    var websites = ["hackingwithswift.com", "raywenderlich.com", "swiftbysundell.com", "useyourloaf.com", "udemy.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "iOS Swift Resources 📚"
        
    }
    // define number of rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    // dequeue reusable cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "websiteURL", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    
    // push selected website to view controller
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "websiteView") as? ViewController {
            vc.selectedWebsite = websites[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

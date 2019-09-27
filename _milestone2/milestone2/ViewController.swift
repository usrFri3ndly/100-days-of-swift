//
//  ViewController.swift
//  milestone2
//
//  Created by Sc0tt on 26/09/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    // list array
    var shoppingList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
         
        // create navigation buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteList))

        // large title for list
        title = "Shopping 🛒"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // determine number of rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    // dequeue used cells to improve performance
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listItem = tableView.dequeueReusableCell(withIdentifier: "listItem", for: indexPath)
        listItem.textLabel?.text = shoppingList[indexPath.row]
        return listItem
    }
    
    // if user taps on cell add/remove checkmark
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
    }
    
    
    // add item to list
    @objc func addItem() {
        let ac = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        
        // cancel add
        let cancelButton = UIAlertAction(title: "Canel", style: .cancel)
        
        // submit item
        let submitButton = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let item = ac?.textFields?[0].text else { return }
            self?.submit(item)
        }
        
        // show ac and buttons
        ac.addTextField()
        ac.addAction(cancelButton)
        ac.addAction(submitButton)
        present(ac, animated: true)
    }
    
    // add item to shoppingList array
    func submit(_ item: String)
    {
        shoppingList.insert(item, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        return
    }
    
    // delete items & start new list
    @objc func deleteList() {
        let ac = UIAlertController(title: "Delete List", message: "This will delete all items that are currently in the list.", preferredStyle: .alert)
        
        // cancel
        let cancelButton = UIAlertAction(title: "Canel", style: .cancel)
        
        // delete
        let deleteButton = UIAlertAction(title: "DELETE", style: .default) {
            [weak self] _ in
            self?.shoppingList.removeAll(keepingCapacity: true)
            self?.tableView.reloadData()
        }

        // show ac and buttons
        ac.addAction(cancelButton)
        ac.addAction(deleteButton)
        present(ac, animated: true)
    }
}


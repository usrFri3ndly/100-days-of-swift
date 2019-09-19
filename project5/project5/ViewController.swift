//
//  ViewController.swift
//  project5
//
//  Created by Sc0tt on 16/09/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    // initialise word arrays
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        // look for file with extension
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // attempt to read contents of file and add too allWords
            if let startWords = try? String(contentsOf: startWordsURL)
            {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            // if file is empty
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    // pick random word when game starts and clear any previous values
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    //
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        // add text field to alert controller
        ac.addTextField()
        
        // closure for text input
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    // add word to usedWords if checks pass
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        // ensure word conditions are met
        if lowerAnswer == title {
            return showErrorMessage(errorTitle: "No Cheating", errorMessage: "Your answer can't include the game word!")
        }
        
        if lowerAnswer.count < 3 {
                return showErrorMessage(errorTitle: "Answer Too Short", errorMessage: "Answers must be at least 3 characters.")
        }
        
        if !isPossible(word: lowerAnswer) {
            return showErrorMessage(errorTitle: "Answer Not Possible", errorMessage: "You can't spell '\(lowerAnswer)' from '\(title!.lowercased())'.")
        }
        
        if !isOriginal(word: lowerAnswer) {
            return showErrorMessage(errorTitle: "Answer Not Original", errorMessage: "You've already used this one!")
        }
        
        if !isReal(word: lowerAnswer)
        {
            return showErrorMessage(errorTitle: "Answer Not Recognised", errorMessage: "Is this even a real word?")
        } else {
            //insert into usedWords at top of table
            usedWords.insert(answer, at: 0)
            // create new row to show new cell rather than reloading whole
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            return
        }
    }

    // display error message with returned values
    func showErrorMessage(errorTitle: String, errorMessage: String) -> Void {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        // use title as comparison word
        guard var tempWord = title?.lowercased() else { return false }
        
        // loop over each letter
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    // ensure usedWords does not contain answer
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
                let checker = UITextChecker()
                // scan range for checker
                let range = NSRange(location: 0, length: word.utf16.count)
                let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
                return misspelledRange.location == NSNotFound
    }
}


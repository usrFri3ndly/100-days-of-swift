//
//  ViewController.swift
//  project28
//
//  Created by Sc0tt on 02/01/2020.
//  Copyright © 2020 Sc0tt. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    @IBOutlet var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        // allow text view to adjust contents and scroll insets when keyboard appears/disappears
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // run method when user leaves the app
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }


    @IBAction func authenticateTapped(_ sender: Any) {
        // new local authentication context
        let context = LAContext()
        // objective c
        var error: NSError?
        
        // can biometric identification be used
        // &error - pointer to error location in ram [can be overwritten]
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // only shown to devices with touch id
            // key added to info.plist for face id
            let reason = "Identify yourself!"
            
            // attempt authentication
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                // use main thread asyncrhonously whilst waiting for input from user
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        // error
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified, please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated:  true)
                    }
                }
            }
        } else {
            // no biometrics
            let ac = UIAlertController(title: "Biometrics Unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        // size of keyboard relative to screen
        let keyboardScreenEnd = keyboardValue.cgRectValue
        // convert window coordinates to view coordinates [rotation etc..]
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            // inset content from bottom if keboard is present
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        // scroll view matches size of text view
        secret.scrollIndicatorInsets = secret.contentInset
        
        // scroll to whatever text was selected
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        // if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
        //     secret.text = text
        // }
        
        // read saved string from keychain and place text in textView
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(saveSecretMessage))
    }
    
    @objc func saveSecretMessage() {
        // check if secret is not hidden
        guard secret.isHidden == false else { return }
        // hide 'done' button
        navigationItem.setRightBarButton(nil, animated: true)
        
        // write text to keychain
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        // make textView stop being active
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
    }
    
}


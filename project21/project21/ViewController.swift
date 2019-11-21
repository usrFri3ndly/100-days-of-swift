//
//  ViewController.swift
//  project21
//
//  Created by Sc0tt on 19/11/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit
// import required framework for notifications
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create navigation items
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleTapped))
    }

    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        // show alert, badge and sound
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, error in
            if granted {
                print("Yay!")
            } else {
                print("Nay!")
            }
        }
    }
    
    // set initial schedule of 5 seconds when button is tapped
    @objc func scheduleTapped() {
        scheduleLocal(interval: 5)
    }
    
    @objc func scheduleLocal(interval: Double) {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        // cancel notifcations that are scheduled but not yet delivered
        center.removeAllPendingNotificationRequests()
        
        // notification content to show
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = .default
        
        /* trigger for notification
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true) */
        
        // trigger for notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        
        // tie content and trigger together in request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories () {
        let center = UNUserNotificationCenter.current()
        // messages from notifcations get reported back to viewController
        center.delegate = self
        
        // allow user to choose view actions for notification
        // will run immediately in foreground
        let dismiss = UNNotificationAction(identifier: "dismiss", title: "I'm Up Already! 🌞", options: .foreground)
        let snooze = UNNotificationAction(identifier: "snooze", title: "Snooze [10 Seconds]... 😴", options: .foreground)
        
        // wrap in notifcation category
        let category = UNNotificationCategory(identifier: "alarm", actions: [dismiss, snooze], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // look for customData key
        if let customData = userInfo["customData"] as? String {
            print("Custom data recieved: \(customData)")
            
            // responses based on users action identifier choice
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // swiped to unlock
                print("Default identifier")
                
            case "dismiss":
                showAC(message: "👍🏼 Time to get your Swift on!")
            case "snooze":
                scheduleLocal(interval: 10)
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    // run function with passed parameters
    func showAC(message: String) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Done", style: .cancel))
        present(ac, animated: true)
    }
}


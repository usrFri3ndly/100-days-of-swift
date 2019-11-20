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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
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
    
    @objc func scheduleLocal() {
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
        
        // trigger for notification
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // tie content and trigger together in request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories () {
        let center = UNUserNotificationCenter.current()
        // messages from notifcations get reported back to viewController
        center.delegate = self
        
        // launch app imediately in foreground
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        
        // wrap in notifcation category
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // look for customData key
        if let customData = userInfo["customData"] as? String {
            print("Custom data recieved: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // swiped to unlock
                print("Default identifier")
            case "show":
                print("Show more information...")
            default:
                break
            }
        }
        
        completionHandler()
    }

}


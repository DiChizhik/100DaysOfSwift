//
//  ViewController.swift
//  Project 22 notificationsCentre
//
//  Created by Diana Chizhik on 17/06/2022.
//
import NotificationCenter
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    var timeInterval: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
    }
    
    @objc func registerLocal() {
        let centre = UNUserNotificationCenter.current()
        centre.requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, error in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
    }
    
    @objc func scheduleLocal() {
        registerCategories()
        let centre = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Alarm clock"
        content.body = "Lift your butt off the bed, Honey"
        content.sound = .default
        content.categoryIdentifier = "alarm"
        content.userInfo = ["username": "Diana"]
        
//        var dateComponents = DateComponents()
//        dateComponents.hour = 10
//        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        timeInterval = 10
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        centre.add(request)
    }
    
    func registerCategories() {
        let centre = UNUserNotificationCenter.current()
        centre.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more", options: .foreground)
        let remind = UNNotificationAction(identifier: "remind", title: "Remind me later")
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remind], intentIdentifiers: [])
        centre.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let username = userInfo["username"] as? String {
            print("User name is \(username)")
        }
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            showAlert(title: "Welcome back!", message: nil)
        case "show":
            showAlert(title: "Hi, Di", message: "You're finally up!")
        case "remind":
            timeInterval = 30
            scheduleLocal()
        default:
            break
        }
        
        completionHandler()

        
        
    }
    
    func showAlert(title: String, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

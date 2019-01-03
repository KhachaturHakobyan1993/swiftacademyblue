//
//  ViewController.swift
//  Local Notifications
//
//  Created by Khachatur Hakobyan on 1/3/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBarButtons()
    }
    

    // MARK: - Methods Setup -
    
    private func setupBarButtons() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(ViewController.registerLocal))
        let scheduleButton = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(ViewController.scheduleLocal))
        let scheduleIMGButton = UIBarButtonItem(title: "Schedule + IMG", style: .plain, target: self, action: #selector(ViewController.scheduleLocalWithIMG))
        self.navigationItem.rightBarButtonItems = [scheduleButton, scheduleIMGButton]
    }
    
    
    // MARK: - Methods -
    
    
    @objc private func registerLocal() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [unowned self] (success, error) in
            guard let _ = error else {
                debugPrint("requestAuthorization success = \(success)")
                return
            }
            self.showAlertForError(.perission)
        }
    }
    
    @objc private func scheduleLocal() {
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        var dateComponents = DateComponents()
//        dateComponents.hour = 20
//        dateComponents.minute = 44
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.badge = 33
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        self.registerCategories()
        UNUserNotificationCenter.current().add(request) {  [unowned self] (error) in
            guard let _ = error else { return }
            self.showAlertForError(.request)
        }
    }
    
    @objc private func scheduleLocalWithIMG() {
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let content = UNMutableNotificationContent()
        content.title = "IMG Late wake up call"
        content.body = "IMG The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "IMG-alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.badge = 55
        let url = Bundle.main.url(forResource: "imgLaunch", withExtension: "png")
        let attachment = try! UNNotificationAttachment(identifier: "image", url: url!, options: [:])
        content.attachments = [attachment]
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        self.registerCategories()
        UNUserNotificationCenter.current().add(request) {  [unowned self] (error) in
            guard let _ = error else { return }
            self.showAlertForError(.request)
        }
    }
    
    private func registerCategories() {
        let showAction = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        let rejectAction = UNNotificationAction(identifier: "reject", title: "Reject", options: .authenticationRequired)
        let okAction = UNNotificationAction(identifier: "ok", title: "OK", options: .destructive)
        let category = UNNotificationCategory(identifier: "alarm", actions: [showAction, rejectAction, okAction], intentIdentifiers: [], options: [])
        let likeAction = UNNotificationAction(identifier: "like", title: "Like", options: .authenticationRequired)
        let dislikeAction = UNNotificationAction(identifier: "dislike", title: "Dislike", options: .authenticationRequired)
        let categoryIMG = UNNotificationCategory(identifier: "IMG-alarm", actions: [likeAction, dislikeAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().setNotificationCategories([category, categoryIMG])
    }
    
    private func showAlertForError(_ error: CustomError) {
        let alertVC = UIAlertController(title: error.rawValue, message: error.info, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }

    fileprivate enum CustomError:String, Error {
        case perission = "UNUserNotificationCenter Permission Error!"
        case request = "UNUserNotificationCenter Request Error!"
        var info: String {
            return (self as NSError).userInfo.description
        }
    }
}


// MARK: - UNUserNotificationCenterDelegate -

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            debugPrint("Custom data received: \(customData)")
        }
        debugPrint("Notification identifier ", response.notification.request.identifier)

        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            debugPrint("Default identifier")
        case "show":
            debugPrint("Tell me more.. Tapped")
        case "reject":
            debugPrint("Reject Tapped…")
        case "ok":
            debugPrint("OK Tapped…")
        case "like":
            debugPrint("Like Tapped…")
        case "dislike":
            debugPrint("Dislike Tapped…")
        default:
            break
        }
        completionHandler()
    }
}


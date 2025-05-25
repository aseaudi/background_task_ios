//
//  ViewController.swift
//  test123
//
//  Created by Abdelmuhaimen Seaudi on 24/05/2025.
//

import UIKit
import UserNotifications
import BackgroundTasks

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    let taskId = "aseaudi.test123.task"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkForPermission()
        print("got permissions")
        dispatchNotification()
        
    }
    
    func scheduleTask() {
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            print("\(requests.count) BGTasks pending")
            guard requests.isEmpty else {
                return
            }
            // Submit task to be scheduled
            do {
                let newTask = BGAppRefreshTaskRequest(identifier: self.taskId)
                newTask.earliestBeginDate = Date().addingTimeInterval(1)
                try BGTaskScheduler.shared.submit(newTask)
                print("Task scheduled")
            } catch {
                print("Task failed to schedule \(error)")
            }

        }
    }
    
    func checkForPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification()
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.dispatchNotification()
                    }
                }
            default:
                return
            }
        }
    }
        
    func dispatchNotification() {
        let id = "notification1"
        let title = "BGTask title"
        let body = "BGTask Body"
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let date = Date().addingTimeInterval(5)
        let dateComponent = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.delegate = self
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        notificationCenter.add(request, withCompletionHandler: nil)

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   willPresent notification: UNNotification,
                                   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.sound])
       }
    
    }
    


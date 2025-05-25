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
    
    let notificationPublisher = NotificationPublisher()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkForPermission()
        print("got permissions")
        print("wait 20 seconds")
        sleep(5)
        dispatchNotification()
//        showProgressNotification()
//        sleep(30)
//        removeProgressNotification()
        
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
//                self.dispatchNotification()
                return
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
//                        self.dispatchNotification()
                        return
                    }
                }
            default:
                return
            }
        }
    }
        
    func dispatchNotification() {
        print("dispatch notification")
        let id = "notification1"
        let title = "Background App"
        let body = "Background task started"
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
        notificationCenter.add(request)

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   willPresent notification: UNNotification,
                                   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.sound])
       }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
        print("notification response received")
        print(response)
            if response.actionIdentifier == UNNotificationDismissActionIdentifier {
                // User swiped it away — re-schedule if still needed
                print("Notification was dismissed")
                // Optionally show it again
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.dispatchNotification()
                }
            }

            completionHandler()
        }
    
    @IBAction func startService(_ sender: Any) {
        notificationPublisher.sendNotification()
    }
    
    func didReceiveLocalNotification() {
        
    }
    
    func showProgressNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Processing..."
        content.body = "Your background task is running."
        content.sound = .default
        content.categoryIdentifier = "TASK_PROGRESS"

        let request = UNNotificationRequest(identifier: "task_progress", content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request)
    }

    func removeProgressNotification() {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["task_progress"])
    }
    
    }
    


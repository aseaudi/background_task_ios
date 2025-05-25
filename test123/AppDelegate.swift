//
//  AppDelegate.swift
//  test123
//
//  Created by Abdelmuhaimen Seaudi on 24/05/2025.
//

import UIKit
import BackgroundTasks
import UserNotifications



@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let taskId = "aseaudi.test123.task"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerNotificationCategories()

        
        // Register handler for task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) {task in
            guard let task = task as? BGAppRefreshTask else { return}
            self.handleTask(task: task)
        }
        let count = UserDefaults.standard.integer(forKey: "task_count")
        print("Task ran \(count) times")
        
//        scheduleTask()
        
        
        return true
    }
    
    func registerNotificationCategories() {
        let category = UNNotificationCategory(
            identifier: "STICKY_CATEGORY",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
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
    
    func handleTask(task: BGAppRefreshTask) {
        let count = UserDefaults.standard.integer(forKey: "task_count")
        UserDefaults.standard.set(count + 1, forKey: "task_count")
        showProgressNotification()
        sleep(10)
        removeProgressNotification()
        task.expirationHandler = {
            // pass
        }
        task.setTaskCompleted(success: true)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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

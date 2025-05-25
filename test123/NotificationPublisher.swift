//
//  NotificationPublisher.swift
//  test123
//
//  Created by Abdelmuhaimen Seaudi on 25/05/2025.
//

import UserNotifications

class NotificationPublisher: NSObject, UNUserNotificationCenterDelegate {
    
    func sendNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "My App"
        content.body = "New task is created"
        content.subtitle = "New subtitle"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(5),repeats: false)
        UNUserNotificationCenter.current().delegate = self
        let request = UNNotificationRequest(identifier: "notification2", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   willPresent notification: UNNotification,
                                   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("notificiation willPresent")
        completionHandler([.sound, .banner])
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
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                sleep(3)
                    self.sendNotification()
//                }
            }
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print("Notification default action")
        }

            completionHandler()
        }
    
}

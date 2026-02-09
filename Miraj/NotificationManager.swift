//
//  NotificationManager.swift
//  Miraj
//
//  Created by Sijan Shrestha on 2/9/26.
//

import UserNotifications

struct NotificationManager {

    static func requestPermissionAndSchedule() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                schedulePostReminder()
            }
        }
    }

    static func schedulePostReminder() {
        let center = UNUserNotificationCenter.current()

        // Remove any existing reminders before scheduling
        center.removePendingNotificationRequests(withIdentifiers: ["miraj_post_reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Miraj"
        content.body = "Don't forget to share your moment today!"
        content.sound = .default

        // Remind every 8 hours
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8 * 60 * 60, repeats: true)
        let request = UNNotificationRequest(identifier: "miraj_post_reminder", content: content, trigger: trigger)

        center.add(request) { _ in }
    }

    static func unregisterNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}

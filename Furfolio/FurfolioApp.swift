//
//  FurfolioApp.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//
//
import SwiftUI
import SwiftData
import UserNotifications

@main
struct FurfolioApp: App {
    private var sharedModelContainer: ModelContainer = {
        do {
            let schema = try Schema([DogOwner.self, Charge.self, Appointment.self])
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }()

    init() {
        requestNotificationPermissions()
        UNUserNotificationCenter.current().delegate = NotificationDelegate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission request failed: \(error.localizedDescription)")
                } else {
                    print(granted ? "Notification permission granted." : "Notification permission denied.")
                }
            }
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification will be presented: \(notification.request.content.body)")
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification received: \(response.notification.request.content.body)")
        completionHandler()
    }
}

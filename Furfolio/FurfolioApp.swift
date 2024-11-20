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
    // Shared model container for managing app data
    private var sharedModelContainer: ModelContainer = {
        do {
            let schema = try Schema([DogOwner.self, Charge.self, Appointment.self])
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }()

    init() {
        // Request notification permissions
        requestNotificationPermissions()
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer) // Attach model container to the app's views
        }
    }

    /// Request notification permissions with error handling
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission request failed: \(error.localizedDescription)")
            } else {
                print(granted ? "Notification permission granted." : "Notification permission denied.")
            }
        }
    }
}

// Notification Delegate to handle user notification events
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Present notifications while the app is in the foreground
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle user interaction with a notification
        print("Notification received: \(response.notification.request.content.body)")
        completionHandler()
    }
}

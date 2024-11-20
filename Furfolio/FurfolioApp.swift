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

// Notification Delegate to handle user notification events
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // Called when a notification is about to be presented
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Present notifications while the app is in the foreground
        print("Notification will be presented: \(notification.request.content.body)")
        completionHandler([.alert, .sound])  // Show the alert and play the sound when the app is in the foreground
    }

    // Called when the user interacts with a notification (e.g., taps on it)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle user interaction with a notification
        print("Notification received: \(response.notification.request.content.body)")
        
        if response.actionIdentifier == "Snooze" {
            // Handle snooze action, e.g., reschedule notification
            print("Snooze action selected")
        } else if response.actionIdentifier == "View" {
            // Handle view appointment action, navigate to appointment view
            print("View Appointment action selected")
        }

        // Call completion handler to signal that the notification response was handled
        completionHandler()
    }
}

// Add custom actions to notifications
func setupNotificationActions() {
    let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: .foreground)
    let viewAction = UNNotificationAction(identifier: "View", title: "View Appointment", options: .foreground)

    let category = UNNotificationCategory(identifier: "AppointmentReminder", actions: [snoozeAction, viewAction], intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([category])
}

// Schedule appointment reminder notification
func scheduleAppointmentReminder(for appointment: Appointment) {
    let content = UNMutableNotificationContent()
    content.title = "Upcoming Appointment"
    content.body = "You have an appointment with \(appointment.dogOwner.ownerName) at \(appointment.date.formatted())"
    content.categoryIdentifier = "AppointmentReminder"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60 * 24, repeats: false) // 24 hours before
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error.localizedDescription)")
        } else {
            print("Notification scheduled successfully.")
        }
    }
}

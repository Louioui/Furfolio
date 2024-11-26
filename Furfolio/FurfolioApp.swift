//
//  FurfolioApp.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct FurfolioApp: App {
    // Initialize shared model container for the app
    private var sharedModelContainer: ModelContainer = {
        do {
            let schema = try Schema([DogOwner.self, Charge.self, Appointment.self, DailyRevenue.self])
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }()

    init() {
        configureNotifications()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer) // Attach model container to the app's views
                .onReceive(NotificationCenter.default.publisher(for: .addDogOwnerShortcut)) { _ in
                    handleAddDogOwnerShortcut()
                }
                .onReceive(NotificationCenter.default.publisher(for: .viewMetricsShortcut)) { _ in
                    handleViewMetricsShortcut()
                }
        }
        .commands {
            // Add App Commands for Quick Actions
            CommandMenu("Shortcuts") {
                Button("Add New Dog Owner") {
                    NotificationCenter.default.post(name: .addDogOwnerShortcut, object: nil)
                }
                .keyboardShortcut("N", modifiers: [.command])

                Button("View Metrics Dashboard") {
                    NotificationCenter.default.post(name: .viewMetricsShortcut, object: nil)
                }
                .keyboardShortcut("M", modifiers: [.command])
            }
        }
    }

    // MARK: - Notification Configuration

    /// Configures notification settings and delegates
    private func configureNotifications() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate()
        requestNotificationPermissions()
    }

    /// Requests notification permissions from the user
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

    // MARK: - Shortcut Handlers

    /// Handles the "Add Dog Owner" shortcut action
    private func handleAddDogOwnerShortcut() {
        NotificationCenter.default.post(name: .showAddOwnerSheet, object: nil)
    }

    /// Handles the "View Metrics Dashboard" shortcut action
    private func handleViewMetricsShortcut() {
        NotificationCenter.default.post(name: .showMetricsDashboard, object: nil)
    }
}

// MARK: - Notification Delegate

/// Handles user notification events
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("Notification will be presented: \(notification.request.content.body)")
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("Notification received: \(response.notification.request.content.body)")
        completionHandler()
    }
}

// MARK: - Notification Names

/// Extend `Notification.Name` for app-specific events
extension Notification.Name {
    static let addDogOwnerShortcut = Notification.Name("addDogOwnerShortcut")
    static let viewMetricsShortcut = Notification.Name("viewMetricsShortcut")
    static let showAddOwnerSheet = Notification.Name("showAddOwnerSheet")
    static let showMetricsDashboard = Notification.Name("showMetricsDashboard")
}


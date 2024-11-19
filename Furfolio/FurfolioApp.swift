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
struct demoApp: App {
   // Correcting the ModelContainer initialization
   var sharedModelContainer: ModelContainer = {
       do {
           // Ensure the models are being included in the schema correctly
           let schema = try Schema([DogOwner.self, Charge.self, Appointment.self])
           let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
           
           return try ModelContainer(for: schema, configurations: [modelConfiguration])
       } catch {
           fatalError("Could not create ModelContainer: \(error)")
       }
   }()

   // Request notification permission when the app starts
   init() {
       UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
           if let error = error {
               print("Notification permission request failed: \(error.localizedDescription)")
           } else if granted {
               print("Notification permission granted.")
           } else {
               print("Notification permission denied.")
           }
       }
       
       // Set the delegate to handle notifications
       UNUserNotificationCenter.current().delegate = NotificationDelegate()
   }

   var body: some Scene {
       WindowGroup {
           ContentView()
               .modelContainer(sharedModelContainer) // Ensure the model container is applied here
       }
   }
}

// Notification Delegate to handle foreground notifications
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
   func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       // Present the notification even when the app is in the foreground
       completionHandler([.alert, .sound])
   }

   func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       // Handle the notification action if needed
       print("Notification received: \(response.notification.request.content.body)")
       completionHandler()
   }
}

//
//  AppointmentReminderView.swift
//  Furfolio
//
//  Created by mac on 11/20/24.

import SwiftUI
import UserNotifications

// Define the shared DateFormatter to be used globally
private let globalAppointmentDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct AppointmentReminderView: View {
    let dogOwners: [DogOwner]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dogOwners) { owner in
                    if let nextAppointment = owner.nextAppointment {
                        VStack(alignment: .leading) {
                            Text("\(owner.ownerName)'s Next Appointment")
                                .font(.headline)
                            // Use the globally declared formatter here
                            Text("Date: \(globalAppointmentDateFormatter.string(from: nextAppointment.date))")
                            Text("Reminder: 24 hours before appointment")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Button("Set Reminder") {
                                // Call the function to schedule the reminder
                                scheduleAppointmentReminder(for: nextAppointment)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Appointment Reminders")
        }
    }
    
    func scheduleAppointmentReminder(for appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Appointment"
        content.body = "You have an appointment with \(appointment.dogOwner.dogName) on \(globalAppointmentDateFormatter.string(from: appointment.date))."
        content.sound = .default
        
        // Trigger 24 hours before the appointment
        let triggerDate = Calendar.current.date(byAdding: .hour, value: -24, to: appointment.date)!
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerDate.timeIntervalSinceNow, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Reminder scheduled for \(appointment.dogOwner.ownerName)'s appointment.")
            }
        }
    }
}

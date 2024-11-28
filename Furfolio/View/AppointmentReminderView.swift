//
//  AppointmentReminderView.swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//

import SwiftUI
import UserNotifications

// Define a shared DateFormatter to be used globally
private let globalAppointmentDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct AppointmentReminderView: View {
    let dogOwners: [DogOwner]
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(dogOwners) { owner in
                    if let nextAppointment = owner.nextAppointment {
                        Section(header: Text(owner.ownerName)) {
                            reminderRow(for: nextAppointment, owner: owner)
                        }
                    } else {
                        Text("\(owner.ownerName) has no upcoming appointments.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Appointment Reminders")
            .alert("Notification Status", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Reminder Row

    /// Generates a row for the reminder
    private func reminderRow(for appointment: Appointment, owner: DogOwner) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next Appointment: \(globalAppointmentDateFormatter.string(from: appointment.date))")
                .font(.subheadline)

            if let notes = appointment.notes, !notes.isEmpty {
                Text("Notes: \(notes)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("Reminder: 24 hours before appointment")
                .font(.caption)
                .foregroundColor(.gray)

            Button("Set Reminder") {
                scheduleAppointmentReminder(for: appointment, owner: owner)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canScheduleReminder(for: appointment))
            .opacity(canScheduleReminder(for: appointment) ? 1.0 : 0.5)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Reminder Scheduling

    /// Schedules a notification reminder for the given appointment
    private func scheduleAppointmentReminder(for appointment: Appointment, owner: DogOwner) {
        guard let triggerDate = Calendar.current.date(byAdding: .hour, value: -24, to: appointment.date),
              triggerDate > Date() else {
            alertMessage = "The appointment is too soon to schedule a reminder."
            showAlert = true
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Appointment"
        content.body = "You have an appointment with \(owner.ownerName) for \(owner.dogName) on \(globalAppointmentDateFormatter.string(from: appointment.date))."
        if let notes = appointment.notes, !notes.isEmpty {
            content.body += " Notes: \(notes)"
        }
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                alertMessage = "Failed to schedule notification: \(error.localizedDescription)"
            } else {
                alertMessage = "Reminder successfully scheduled for \(owner.ownerName)'s appointment."
            }
            showAlert = true
        }
    }

    // MARK: - Helper Methods

    /// Checks if a reminder can be scheduled for the given appointment
    private func canScheduleReminder(for appointment: Appointment) -> Bool {
        guard let triggerDate = Calendar.current.date(byAdding: .hour, value: -24, to: appointment.date) else {
            return false
        }
        return triggerDate > Date()
    }
}

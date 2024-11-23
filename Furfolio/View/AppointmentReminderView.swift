//
//  AppointmentReminderView.swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//
import SwiftUI
import UserNotifications

private let globalAppointmentDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct AppointmentReminderView: View {
    @State private var dogOwners: [DogOwner] = [] // State-managed array

    var body: some View {
        NavigationView {
            List {
                // Use the plain array and specify 'id' for uniqueness
                ForEach(dogOwners, id: \.id) { owner in
                    if let nextAppointment = owner.nextAppointment {
                        VStack(alignment: .leading) {
                            Text("\(owner.ownerName)'s Next Appointment")
                                .font(.headline)
                            Text("Date: \(globalAppointmentDateFormatter.string(from: nextAppointment.date))")
                            Text("Reminder: 24 hours before appointment")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Button("Set Reminder") {
                                scheduleAppointmentReminder(for: nextAppointment)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Appointment Reminders")
            .onAppear {
                loadDogOwners()
            }
        }
    }

    func scheduleAppointmentReminder(for appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Appointment"
        content.body = "You have an appointment with \(appointment.dogOwner.dogName) on \(globalAppointmentDateFormatter.string(from: appointment.date))."
        content.sound = .default

        // Calculate the trigger time (24 hours before the appointment)
        guard let triggerDate = Calendar.current.date(byAdding: .hour, value: -24, to: appointment.date) else {
            print("Failed to calculate trigger date")
            return
        }

        // Create the notification trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)

        // Create the notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Reminder scheduled for \(appointment.dogOwner.ownerName)'s appointment.")
            }
        }
    }

    private func loadDogOwners() {
        // Load data from your model context or API here
        // Example: dogOwners = fetchDogOwnersFromContext()
    }
}


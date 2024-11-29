//
//  AddAppointmentView.swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//

import SwiftUI
import UserNotifications

struct AddAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let dogOwner: DogOwner

    @State private var appointmentDate = Date()
    @State private var serviceType: Appointment.ServiceType = .basic
    @State private var appointmentNotes = ""
    @State private var conflictWarning: String? = nil
    @State private var isSaving = false
    @State private var enableReminder = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("Appointment Details", comment: "Section header for appointment details"))) {
                    DatePicker(NSLocalizedString("Appointment Date", comment: "Picker for appointment date"), selection: $appointmentDate, displayedComponents: [.date, .hourAndMinute])
                        .onChange(of: appointmentDate) { _ in
                            conflictWarning = nil
                        }

                    Picker(NSLocalizedString("Service Type", comment: "Picker for selecting service type"), selection: $serviceType) {
                        ForEach(Appointment.ServiceType.allCases, id: \.self) { type in
                            Text(type.localized)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    TextField(NSLocalizedString("Notes (Optional)", comment: "Placeholder for appointment notes"), text: $appointmentNotes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.sentences)

                    Toggle(NSLocalizedString("Enable Reminder", comment: "Toggle for enabling reminders"), isOn: $enableReminder)
                        .onChange(of: enableReminder) { isOn in
                            if isOn {
                                requestNotificationPermission()
                            }
                        }
                }

                if let conflictWarning = conflictWarning {
                    Section {
                        Text(conflictWarning)
                            .foregroundColor(.red)
                            .italic()
                    }
                }
            }
            .navigationTitle(NSLocalizedString("Add Appointment", comment: "Navigation title for Add Appointment view"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("Cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Save", comment: "Save button")) {
                        if validateAppointment() {
                            isSaving = true
                            saveAppointment()
                            dismiss()
                        }
                    }
                    .disabled(!validateFields() || isSaving)
                }
            }
            .alert(NSLocalizedString("Conflict Detected", comment: "Alert title for conflict detection"), isPresented: .constant(conflictWarning != nil)) {
                Button(NSLocalizedString("OK", comment: "Alert confirmation button"), role: .cancel) {}
            } message: {
                Text(conflictWarning ?? "")
            }
        }
    }

    // MARK: - Validation Methods

    /// Validates the appointment and checks for conflicts
    private func validateAppointment() -> Bool {
        guard validateFields() else { return false }
        if !checkConflicts() {
            conflictWarning = NSLocalizedString("This appointment conflicts with another!", comment: "Conflict warning message")
            return false
        }
        return true
    }

    /// Ensures required fields are filled
    private func validateFields() -> Bool {
        appointmentDate > Date()
    }

    /// Checks for conflicting appointments
    private func checkConflicts() -> Bool {
        !dogOwner.appointments.contains { abs($0.date.timeIntervalSince(appointmentDate)) < 3600 }
    }

    // MARK: - Save Method

    /// Saves the appointment to the model context
    private func saveAppointment() {
        let newAppointment = Appointment(date: appointmentDate, dogOwner: dogOwner, serviceType: serviceType, notes: appointmentNotes)
        withAnimation {
            modelContext.insert(newAppointment)
            dogOwner.appointments.append(newAppointment)
        }

        if enableReminder {
            scheduleReminder(for: newAppointment)
        }
    }

    // MARK: - Reminder Methods

    /// Schedules a reminder notification for the appointment
    private func scheduleReminder(for appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Upcoming Appointment", comment: "Reminder title")
        content.body = String(format: NSLocalizedString("Appointment with %@ on %@", comment: "Reminder body"), dogOwner.ownerName, appointment.formattedDate)
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .minute, value: -30, to: appointment.date) ?? appointment.date
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error.localizedDescription)")
            }
        }
    }

    /// Requests notification permission from the user
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            if !granted {
                enableReminder = false
                print("User denied notification permissions.")
            }
        }
    }
}

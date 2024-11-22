//
//  AddAppointmentView.swift
//  Furfolio
//
//  Created by mac on 11/19/24.
//
// AddAppointmentView.swift
import SwiftUI

struct AddAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let dogOwner: DogOwner

    @State private var appointmentDate = Date()
    @State private var appointmentNotes = ""
    @State private var isCanceled = false // Track cancellation

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appointment Details")) {
                    DatePicker("Date and Time", selection: $appointmentDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                    TextField("Notes", text: $appointmentNotes)
                    Toggle("Canceled", isOn: $isCanceled) // Toggle for cancellation status
                }
            }
            .navigationTitle("New Appointment")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAppointment()
                        dismiss()
                    }
                    .disabled(appointmentDate < Date())  // Disable if the appointment is in the past
                }
            }
        }
    }

    private func saveAppointment() {
        let newAppointment = Appointment(date: appointmentDate, dogOwner: dogOwner, isCanceled: isCanceled)
        modelContext.insert(newAppointment)  // Insert appointment into the database
        dogOwner.appointments.append(newAppointment)  // Optionally append to dogOwner for UI update
    }
}

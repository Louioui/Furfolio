//
//  AddAppointmentView.swift
//  Furfolio
//
//  Created by mac on 11/19/24.
//
// AddAppointmentView.swift
//
//  AddAppointmentView.swift
//  Furfolio
//
//  Created by mac on 11/19/24.
//
import SwiftUI

struct AddAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let dogOwner: DogOwner

    @State private var appointmentDate = Date()
    @State private var appointmentNotes = ""
    @State private var isCanceled = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appointment Details")) {
                    DatePicker("Date and Time", selection: $appointmentDate, displayedComponents: [.date, .hourAndMinute])
                    TextField("Notes", text: $appointmentNotes)
                    Toggle("Canceled", isOn: $isCanceled)
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
                }
            }
        }
    }

    private func saveAppointment() {
        let newAppointment = Appointment(date: appointmentDate, dogOwner: dogOwner, isCanceled: isCanceled)
        modelContext.insert(newAppointment)
        dogOwner.appointments.append(newAppointment)
    }
}

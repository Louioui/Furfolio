//
//  OwnerProfileView.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//


import SwiftUI

struct OwnerProfileView: View {
    var dogOwner: DogOwner

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Owner Name: \(dogOwner.ownerName)")
                .font(.title2)
            Text("Dog Name: \(dogOwner.dogName)")
                .font(.headline)
            Text("Breed: \(dogOwner.breed)")
                .font(.subheadline)
            Text("Contact Info: \(dogOwner.contactInfo)")
                .font(.subheadline)
            Text("Address: \(dogOwner.address)")
                .font(.subheadline)
            Text("Tags: \(dogOwner.tags)")
                .font(.subheadline)
                .foregroundColor(.gray)

            Divider()

            Text("Notes:") // Label for notes
                .font(.headline)
            Text(dogOwner.notes) // Display the notes here
                .font(.subheadline)
                .foregroundColor(.gray)

            Divider()
            Text("Appointment Schedule")
                .font(.headline)
            List(dogOwner.appointments) { appointment in
                VStack(alignment: .leading) {
                    Text("Date: \(appointment.date.formatted(.dateTime.month().day().year().hour().minute())) - Service: \(appointment.serviceType)")
                        .font(.subheadline)
                        .foregroundColor(appointment.status == .overdue ? .red : .blue)
                    Text("Status: \(appointment.status.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(appointment.status == .completed ? .green : .gray)
                    if let appointmentNotes = appointment.notes {
                        Text("Notes: \(appointmentNotes)") // Display appointment notes
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .navigationTitle("\(dogOwner.ownerName)'s Profile")
    }
}

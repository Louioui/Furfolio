//
// OwnerProfileView.swift
//  Furfolio
//
//  Created by mac on 11/19/24.
//

import SwiftUI

struct OwnerProfileView: View {
    let dogOwner: DogOwner

    var body: some View {
        Form {
            Section(header: Text("Owner Information")) {
                Text("Name: \(dogOwner.ownerName)")
                Text("Contact: \(dogOwner.contactInfo)")
                Text("Address: \(dogOwner.address)")
            }

            Section(header: Text("Dog Information")) {
                Text("Name: \(dogOwner.dogName)")
                Text("Breed: \(dogOwner.breed)")
                Text("Notes: \(dogOwner.notes)")
            }

            Section(header: Text("Appointments")) {
                ForEach(dogOwner.appointments) { appointment in
                    VStack(alignment: .leading) {
                        Text("Appointment on \(appointment.date, formatter: appointmentDateFormatter)")
                        if appointment.isCanceled {
                            Text("Status: Canceled").foregroundColor(.red)
                        } else {
                            Text("Status: Confirmed").foregroundColor(.green)
                        }
                    }
                }
            }

            Section(header: Text("Charge History")) {
                ForEach(dogOwner.charges) { charge in
                    VStack(alignment: .leading) {
                        Text("$\(charge.amount, specifier: "%.2f") - \(charge.type)")
                        Text("Date: \(charge.date, formatter: appointmentDateFormatter)")
                    }
                }
            }
        }
        .navigationTitle("\(dogOwner.ownerName)'s Profile")
    }
}

private let appointmentDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

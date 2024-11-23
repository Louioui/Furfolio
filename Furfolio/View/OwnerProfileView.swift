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

            Section(header: Text("Appointments")) {
                ForEach(dogOwner.appointments) { appointment in
                    VStack(alignment: .leading) {
                        Text("Appointment on \(appointment.date, style: .date)")
                        Text("Status: \(appointment.isCanceled ? "Canceled" : "Confirmed")")
                            .foregroundColor(appointment.isCanceled ? .red : .green)
                    }
                }
            }

            Section(header: Text("Charge History")) {
                ForEach(dogOwner.charges) { charge in
                    VStack(alignment: .leading) {
                        Text("$\(charge.amount, specifier: "%.2f") - \(charge.type)")
                        Text("Date: \(charge.date, style: .date)")
                    }
                }
            }
        }
        .navigationTitle(dogOwner.ownerName)
    }
}

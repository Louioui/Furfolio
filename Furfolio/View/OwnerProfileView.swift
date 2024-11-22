//
// OwnerProfileView.swift
//  Furfolio
//
//  Created by mac on 11/19/24.
//

import SwiftUI
import PhotosUI

struct OwnerProfileView: View {
    let dogOwner: DogOwner

    var body: some View {
        Form {
            Section(header: Text("Owner Information")) {
                Text("Owner Name: \(dogOwner.ownerName)")
                Text("Contact Info: \(dogOwner.contactInfo)")
                Text("Address: \(dogOwner.address)")
            }

            Section(header: Text("Dog Information")) {
                Text("Dog Name: \(dogOwner.dogName)")
                Text("Breed: \(dogOwner.breed)")
                Text("Notes: \(dogOwner.notes)")
            }

            Section(header: Text("Appointments")) {
                ForEach(dogOwner.appointments) { appointment in
                    Text("Appointment on \(appointment.date)")
                }
            }

            Section(header: Text("Charge History")) {
                ForEach(dogOwner.charges) { charge in
                    Text("Charge: \(charge.amount) for \(charge.type) on \(charge.date)")
                }
            }
        }
        .navigationTitle("\(dogOwner.ownerName)'s Profile")
    }
}

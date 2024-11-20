//
//  DogOwnerListView.swift
//  Furfolio
//
//  Created by mac on 11/19/24.
//

import SwiftUI
import PhotosUI


struct OwnerProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showNewAppointmentSheet = false
    @State private var showNewChargeSheet = false

    let dogOwner: DogOwner

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Dog Owner Image
                if let dogImage = dogOwner.dogImage, let uiImage = UIImage(data: dogImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                }

                // Owner and Dog Info
                VStack(alignment: .leading, spacing: 10) {
                    Text("Owner: \(dogOwner.ownerName)")
                        .font(.headline)
                    Text("Contact: \(dogOwner.contactInfo)")
                        .font(.subheadline)
                    Text("Address: \(dogOwner.address)")
                        .font(.subheadline)
                    Text("Dog: \(dogOwner.dogName) (\(dogOwner.breed))")
                        .font(.subheadline)
                    if !dogOwner.notes.isEmpty {
                        Text("Notes: \(dogOwner.notes)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                // Appointments Section
                Section(header: Text("Appointments")) {
                    if dogOwner.appointments.isEmpty {
                        Text("No upcoming appointments.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(dogOwner.appointments) { appointment in
                            HStack {
                                Text(appointment.date, style: .date)
                                Spacer()
                                Text(appointment.date, style: .time)
                            }
                        }
                    }
                    Button("Add Appointment") {
                        showNewAppointmentSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }

                // Charges Section
                Section(header: Text("Charge History")) {
                    if dogOwner.charges.isEmpty {
                        Text("No charges recorded.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(dogOwner.charges) { charge in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(charge.type)
                                        .font(.headline)
                                    Text(charge.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text("$\(charge.amount, specifier: "%.2f")")
                                    .font(.headline)
                            }
                        }
                    }
                    Button("Add Charge") {
                        showNewChargeSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showNewAppointmentSheet) {
            AddAppointmentView(dogOwner: dogOwner)
        }
        .sheet(isPresented: $showNewChargeSheet) {
            AddChargeView(dogOwner: dogOwner)
        }
    }
}

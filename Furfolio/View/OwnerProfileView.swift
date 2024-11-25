//
//  OwnerProfileView.swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//

import SwiftUI

struct OwnerProfileView: View {
    let dogOwner: DogOwner

    @State private var isEditing = false
    @State private var showAppointments = true
    @State private var showCharges = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Owner Info Section
                    ownerInfoSection()

                    // Dog Info Section
                    dogInfoSection()

                    // Metrics Section
                    metricsSection()

                    // Appointment History Section
                    if showAppointments {
                        appointmentHistorySection()
                    }

                    // Charge History Section
                    if showCharges {
                        chargeHistorySection()
                    }
                }
                .padding()
            }
            .navigationTitle("Owner Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditing.toggle()
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                EditDogOwnerView(dogOwner: dogOwner) { updatedOwner in
                    // Update logic to replace the dogOwner details in the parent view if needed
                    isEditing = false
                }
            }
        }
    }

    // MARK: - Owner Info Section
    @ViewBuilder
    private func ownerInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dogOwner.ownerName)
                .font(.title)
                .bold()
            if !dogOwner.contactInfo.isEmpty {
                Text("Contact: \(dogOwner.contactInfo)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if !dogOwner.address.isEmpty {
                Text("Address: \(dogOwner.address)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Dog Info Section
    @ViewBuilder
    private func dogInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dog Info")
                .font(.headline)
            Text("Name: \(dogOwner.dogName)")
            Text("Breed: \(dogOwner.breed)")
            if !dogOwner.notes.isEmpty {
                Text("Notes: \(dogOwner.notes)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if let imageData = dogOwner.dogImage, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .padding(.top)
            } else {
                Text("No image available")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Metrics Section
    @ViewBuilder
    private func metricsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Metrics")
                .font(.headline)
            Text("Total Charges: \(dogOwner.totalCharges.formatted(.currency(code: "USD")))")
            Text("Upcoming Appointments: \(dogOwner.hasUpcomingAppointments ? "Yes" : "No")")
            Text("Total Appointments: \(dogOwner.appointments.count)")
            Text("Total Charges Count: \(dogOwner.charges.count)")
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Appointment History Section
    @ViewBuilder
    private func appointmentHistorySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Appointment History")
                    .font(.headline)
                Spacer()
                Button(showAppointments ? "Hide" : "Show") {
                    withAnimation { showAppointments.toggle() }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            if dogOwner.appointments.isEmpty {
                Text("No appointments available.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(dogOwner.appointments.sorted(by: { $0.date > $1.date })) { appointment in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Date: \(appointment.date.formatted(.dateTime.month().day().year()))")
                            Text("Service: \(appointment.serviceType)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if !appointment.notes.isEmpty {
                                Text("Notes: \(appointment.notes)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Charge History Section
    @ViewBuilder
    private func chargeHistorySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Charge History")
                    .font(.headline)
                Spacer()
                Button(showCharges ? "Hide" : "Show") {
                    withAnimation { showCharges.toggle() }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            if dogOwner.charges.isEmpty {
                Text("No charges recorded.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(dogOwner.charges.sorted(by: { $0.date > $1.date })) { charge in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Date: \(charge.date.formatted(.dateTime.month().day().year()))")
                            Text("Type: \(charge.type)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if !charge.notes.isEmpty {
                                Text("Notes: \(charge.notes)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Text("\(charge.amount.formatted(.currency(code: "USD")))")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color.pink.opacity(0.1))
        .cornerRadius(10)
    }
}



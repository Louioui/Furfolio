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
    @State private var showAddAppointment = false
    @State private var showAddCharge = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Owner Info Section
                    ownerInfoSection()

                    // Dog Info Section
                    dogInfoSection()

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
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Image(systemName: "pencil")
                            .font(.title2)
                    }
                    .accessibilityLabel("Edit Owner Profile")
                }
            }
            .sheet(isPresented: $isEditing) {
                EditDogOwnerView(dogOwner: dogOwner) { updatedOwner in
                    isEditing = false
                }
            }
            .sheet(isPresented: $showAddAppointment) {
                AddAppointmentView(dogOwner: dogOwner)
            }
            .sheet(isPresented: $showAddCharge) {
                AddChargeView(dogOwner: dogOwner)
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

    // MARK: - Appointment History Section
    @ViewBuilder
    private func appointmentHistorySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Appointment History")
                    .font(.headline)
                Spacer()
                Button(action: { withAnimation { showAppointments.toggle() } }) {
                    Text(showAppointments ? "Hide" : "Show")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                Button(action: { showAddAppointment = true }) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.headline)
                }
                .foregroundColor(.blue)
            }
            if dogOwner.appointments.isEmpty {
                Text("No appointments available.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(dogOwner.appointments.sorted(by: { $0.date > $1.date })) { appointment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date: \(appointment.date.formatted(.dateTime.month().day().year()))")
                        Text("Service: \(appointment.serviceType.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let notes = appointment.notes, !notes.isEmpty {
                            Text("Notes: \(notes)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
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
                Button(action: { withAnimation { showCharges.toggle() } }) {
                    Text(showCharges ? "Hide" : "Show")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                Button(action: { showAddCharge = true }) {
                    Image(systemName: "plus.circle")
                        .font(.headline)
                }
                .foregroundColor(.blue)
            }
            if dogOwner.charges.isEmpty {
                Text("No charges recorded.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(dogOwner.charges.sorted(by: { $0.date > $1.date })) { charge in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date: \(charge.date.formatted(.dateTime.month().day().year()))")
                            Text("Type: \(charge.type.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let notes = charge.notes, !notes.isEmpty {
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
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.pink.opacity(0.1))
        .cornerRadius(10)
    }
}

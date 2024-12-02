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
    @State private var showHealthRecords = true // Toggle for Health Records
    @State private var showAddAppointment = false
    @State private var showAddCharge = false
    @State private var showAddHealthRecord = false // Toggle for Add Health Record

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Owner Info Section
                    ownerInfoSection()

                    // Dog Info Section
                    dogInfoSection()

                    // Appointment History Section
                    appointmentHistorySection()

                    // Charge History Section
                    chargeHistorySection()

                    // Health Record Section
                    healthRecordHistorySection() // New section for Health Records
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("Owner Profile", comment: "Title for Owner Profile view"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Image(systemName: "pencil")
                            .font(.title2)
                    }
                    .accessibilityLabel(NSLocalizedString("Edit Owner Profile", comment: "Accessibility label for Edit Owner Profile button"))
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
            .sheet(isPresented: $showAddHealthRecord) {
                AddHealthRecordView(dogOwner: dogOwner) { healthRecord in
                    showAddHealthRecord = false
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
            contactInfoText
            addressText
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Dog Info Section
    @ViewBuilder
    private func dogInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("Dog Info", comment: "Header for Dog Info section"))
                .font(.headline)
            Text(String(format: NSLocalizedString("Name: %@", comment: "Dog name label"), dogOwner.dogName))
            Text(String(format: NSLocalizedString("Breed: %@", comment: "Dog breed label"), dogOwner.breed))
            
            // Check if Notes exist and display
            if !dogOwner.notes.isEmpty {
                Text(String(format: NSLocalizedString("Notes: %@", comment: "Dog notes label"), dogOwner.notes))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            dogImageView
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
                Text(NSLocalizedString("Appointment History", comment: "Header for Appointment History section"))
                    .font(.headline)
                Spacer()
                Button(action: { withAnimation { showAppointments.toggle() } }) {
                    Text(showAppointments ? NSLocalizedString("Hide", comment: "Hide button label") : NSLocalizedString("Show", comment: "Show button label"))
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                addAppointmentButton
            }
            appointmentList
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
                Text(NSLocalizedString("Charge History", comment: "Header for Charge History section"))
                    .font(.headline)
                Spacer()
                Button(action: { withAnimation { showCharges.toggle() } }) {
                    Text(showCharges ? NSLocalizedString("Hide", comment: "Hide button label") : NSLocalizedString("Show", comment: "Show button label"))
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                addChargeButton
            }
            chargeList
        }
        .padding()
        .background(Color.pink.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Health Record History Section
    @ViewBuilder
    private func healthRecordHistorySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(NSLocalizedString("Health Record History", comment: "Header for Health Record History section"))
                    .font(.headline)
                Spacer()
                Button(action: { withAnimation { showHealthRecords.toggle() } }) {
                    Text(showHealthRecords ? NSLocalizedString("Hide", comment: "Hide button label") : NSLocalizedString("Show", comment: "Show button label"))
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                addHealthRecordButton
            }
            healthRecordList
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Helper Views
    private var contactInfoText: some View {
        Group {
            if !dogOwner.contactInfo.isEmpty {
                Text(String(format: NSLocalizedString("Contact: %@", comment: "Contact information label"), dogOwner.contactInfo))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var addressText: some View {
        Group {
            if !dogOwner.address.isEmpty {
                Text(String(format: NSLocalizedString("Address: %@", comment: "Address information label"), dogOwner.address))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var dogImageView: some View {
        Group {
            if let imageData = dogOwner.dogImage, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .padding(.top)
            } else {
                Text(NSLocalizedString("No image available", comment: "Message for missing dog image"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    private var addAppointmentButton: some View {
        Button(action: { showAddAppointment = true }) {
            Image(systemName: "calendar.badge.plus")
                .font(.headline)
        }
        .foregroundColor(.blue)
    }

    private var addChargeButton: some View {
        Button(action: { showAddCharge = true }) {
            Image(systemName: "plus.circle")
                .font(.headline)
        }
        .foregroundColor(.blue)
    }

    private var addHealthRecordButton: some View {
        Button(action: { showAddHealthRecord = true }) {
            Image(systemName: "heart.badge.plus")
                .font(.headline)
        }
        .foregroundColor(.blue)
    }

    private var appointmentList: some View {
        Group {
            if dogOwner.appointments.isEmpty {
                Text(NSLocalizedString("No appointments available.", comment: "Message for no appointments"))
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(dogOwner.appointments.sorted(by: { $0.date > $1.date })) { appointment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: NSLocalizedString("Date: %@", comment: "Appointment date label"), appointment.date.formatted(.dateTime.month().day().year())))
                        Text(String(format: NSLocalizedString("Service: %@", comment: "Service type label"), appointment.serviceType.rawValue))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let notes = appointment.notes, !notes.isEmpty {
                            Text(String(format: NSLocalizedString("Notes: %@", comment: "Appointment notes label"), notes))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var chargeList: some View {
        Group {
            if dogOwner.charges.isEmpty {
                Text(NSLocalizedString("No charges recorded.", comment: "Message for no charges"))
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(dogOwner.charges.sorted(by: { $0.date > $1.date })) { charge in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: NSLocalizedString("Date: %@", comment: "Charge date label"), charge.date.formatted(.dateTime.month().day().year())))
                            Text(String(format: NSLocalizedString("Type: %@", comment: "Charge type label"), charge.type.rawValue))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let notes = charge.notes, !notes.isEmpty {
                                Text(String(format: NSLocalizedString("Notes: %@", comment: "Charge notes label"), notes))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Text(charge.amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var healthRecordList: some View {
        Group {
            if dogOwner.healthRecords.isEmpty {
                Text(NSLocalizedString("No health records available.", comment: "Message for no health records"))
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(dogOwner.healthRecords.sorted(by: { $0.date > $1.date })) { record in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: NSLocalizedString("Date: %@", comment: "Health record date label"), record.date.formatted(.dateTime.month().day().year())))
                        Text(String(format: NSLocalizedString("Condition: %@", comment: "Health condition label"), record.healthCondition))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let notes = record.notes, !notes.isEmpty {
                            Text(String(format: NSLocalizedString("Notes: %@", comment: "Health record notes label"), notes))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

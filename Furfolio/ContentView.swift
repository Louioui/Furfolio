//
//  ContentView.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dogOwners: [DogOwner]
    @Query private var dailyRevenues: [DailyRevenue]

    // Search functionality
    @State private var searchText = ""

    // Sheet toggles
    @State private var isShowingAddOwnerSheet = false
    @State private var isShowingMetricsView = false

    // State for selected dog owner
    @State private var selectedDogOwner: DogOwner?

    var body: some View {
        NavigationSplitView {
            // Sidebar List View
            List {
                // Metrics Section
                Section(header: Text("Business Insights")) {
                    Button(action: { isShowingMetricsView = true }) {
                        Label("View Metrics Dashboard", systemImage: "chart.bar.xaxis")
                    }
                }

                // Upcoming Appointments Section
                Section(header: Text("Upcoming Appointments")) {
                    let upcomingAppointments = fetchUpcomingAppointments()

                    if upcomingAppointments.isEmpty {
                        Text("No upcoming appointments.")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(upcomingAppointments) { appointment in
                            if let owner = findOwner(for: appointment) {
                                NavigationLink {
                                    OwnerProfileView(dogOwner: owner)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(owner.ownerName)
                                            .font(.headline)
                                        Text("Next Appointment: \(appointment.date.formatted(.dateTime.month().day().hour().minute()))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        if !appointment.notes.isEmpty {
                                            Text("Notes: \(appointment.notes)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .italic()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Dog Owners Section
                Section(header: Text("Dog Owners")) {
                    let filteredDogOwners = filterDogOwners()

                    if filteredDogOwners.isEmpty {
                        Text("No dog owners found.")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(filteredDogOwners) { dogOwner in
                            NavigationLink {
                                OwnerProfileView(dogOwner: dogOwner)
                            } label: {
                                DogOwnerRowView(dogOwner: dogOwner)
                            }
                        }
                        .onDelete(perform: deleteDogOwners)
                    }
                }
            }
            .navigationTitle("Furfolio")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // "+" button to add a new Dog Owner
                    Button(action: { isShowingAddOwnerSheet = true }) {
                        Label("Add Dog Owner", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddOwnerSheet) {
                AddDogOwnerView { ownerName, dogName, breed, contactInfo, address, notes, selectedImageData in
                    addDogOwner(
                        ownerName: ownerName,
                        dogName: dogName,
                        breed: breed,
                        contactInfo: contactInfo,
                        address: address,
                        notes: notes,
                        selectedImageData: selectedImageData
                    )
                }
            }
            .sheet(isPresented: $isShowingMetricsView) {
                MetricsDashboardView(
                    dailyRevenues: dailyRevenues,
                    appointments: dogOwners.flatMap { $0.appointments },
                    charges: dogOwners.flatMap { $0.charges }
                )
            }
        } detail: {
            if let selectedDogOwner = selectedDogOwner {
                OwnerProfileView(dogOwner: selectedDogOwner)
            } else {
                Text("Select a dog owner to view details.")
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Helper Functions

    /// Filters upcoming appointments within the next 7 days
    private func fetchUpcomingAppointments() -> [Appointment] {
        let today = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: today) ?? today
        return dogOwners.flatMap { $0.appointments }
            .filter { $0.date > today && $0.date <= endDate }
            .sorted { $0.date < $1.date }
    }

    /// Finds the owner for a given appointment
    private func findOwner(for appointment: Appointment) -> DogOwner? {
        dogOwners.first { $0.appointments.contains(appointment) }
    }

    /// Filters dog owners based on the search text
    private func filterDogOwners() -> [DogOwner] {
        dogOwners.filter { owner in
            searchText.isEmpty ||
            owner.ownerName.localizedCaseInsensitiveContains(searchText) ||
            owner.dogName.localizedCaseInsensitiveContains(searchText) ||
            owner.breed.localizedCaseInsensitiveContains(searchText) ||
            owner.address.localizedCaseInsensitiveContains(searchText) ||
            owner.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Adds a new Dog Owner with all details and optional image
    private func addDogOwner(ownerName: String, dogName: String, breed: String, contactInfo: String, address: String, notes: String, selectedImageData: Data?) {
        withAnimation {
            let newOwner = DogOwner(
                ownerName: ownerName,
                dogName: dogName,
                breed: breed,
                contactInfo: contactInfo,
                address: address,
                dogImage: selectedImageData, notes: notes
            )
            modelContext.insert(newOwner)
        }
    }

    /// Deletes selected Dog Owners
    private func deleteDogOwners(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(dogOwners[index])
            }
        }
    }
}



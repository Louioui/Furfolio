//
//  ContentView.swift
//  Furfolio
//
//  Created by mac on 11/18/24.

import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dogOwners: [DogOwner]

    // Search functionality
    @State private var searchText = ""
    
    // Sheet toggles
    @State private var isShowingAddOwnerSheet = false
    @State private var isShowingMetricsView = false // NEW
    
    // State for selected dog owner
    @State private var selectedDogOwner: DogOwner?

    var body: some View {
        NavigationSplitView {
            // Sidebar List View
            List {
                // Metrics Section - NEW
                Section(header: Text("Business Insights")) {
                    Button(action: {
                        isShowingMetricsView = true
                    }) {
                        Label("View Metrics Dashboard", systemImage: "chart.bar.xaxis")
                    }
                }
                
                // Upcoming Appointments Section
                Section(header: Text("Upcoming Appointments")) {
                    let upcomingAppointments = dogOwners.filter { dogOwner in
                        dogOwner.appointments.contains { appointment in
                            let today = Calendar.current.startOfDay(for: Date())
                            return appointment.date > today && appointment.date < today.addingTimeInterval(7 * 24 * 60 * 60)
                        }
                    }
                    
                    if upcomingAppointments.isEmpty {
                        Text("No upcoming appointments.")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(upcomingAppointments) { dogOwner in
                            if let nextAppointment = dogOwner.appointments.sorted(by: { $0.date < $1.date }).first {
                                NavigationLink {
                                    OwnerProfileView(dogOwner: dogOwner)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(dogOwner.ownerName)
                                            .font(.headline)
                                        Text("Next Appointment: \(nextAppointment.date.formatted(.dateTime.month().day().year().hour().minute()))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }

                // Dog Owners Section
                Section(header: Text("Dog Owners")) {
                    let filteredDogOwners = dogOwners.filter { owner in
                        searchText.isEmpty ||
                        owner.ownerName.localizedCaseInsensitiveContains(searchText) ||
                        owner.dogName.localizedCaseInsensitiveContains(searchText)
                    }

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
                AddDogOwnerView { ownerName, dogName, breed, contactInfo, address, selectedImageData in
                    addDogOwner(ownerName: ownerName, dogName: dogName, breed: breed, contactInfo: contactInfo, address: address, selectedImageData: selectedImageData)
                }
            }
            .sheet(isPresented: $isShowingMetricsView) { // NEW
                MetricsDashboardView(dogOwners: dogOwners)
            }
        } detail: {
            if let selectedDogOwner = selectedDogOwner {
                OwnerProfileView(dogOwner: selectedDogOwner)
            } else {
                Text("Select a dog owner to view details.")
            }
        }
    }

    // MARK: - Functions

    /// Adds a new Dog Owner with all details and optional image
    private func addDogOwner(ownerName: String, dogName: String, breed: String, contactInfo: String, address: String, selectedImageData: Data?) {
        withAnimation {
            let newOwner = DogOwner(ownerName: ownerName, dogName: dogName, breed: breed, contactInfo: contactInfo, address: address, dogImage: selectedImageData)
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

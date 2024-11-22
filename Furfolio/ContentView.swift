//
//  ContentView.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//
//


import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(FetchDescriptor<DogOwner>()) private var dogOwners: [DogOwner]
    @Query(FetchDescriptor<DailyRevenue>()) private var dailyRevenues: [DailyRevenue] // Corrected query
    
    // Search functionality
    @State private var searchText = ""
    
    // Sheet toggles
    @State private var isShowingAddOwnerSheet = false
    @State private var isShowingMetricsView = false
    
    // State for selected dog owner
    @State private var selectedDogOwner: DogOwner?
    
    // State for error handling
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // To keep track of the total revenue today
    @State private var totalRevenueToday: Double = 0.0
    
    // Date check for daily revenue reset
    @State private var lastCheckedDate: Date = Date()

    var body: some View {
        NavigationSplitView {
            // Sidebar List View
            List {
                // Metrics Section
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
                    do {
                        try addDogOwner(ownerName: ownerName, dogName: dogName, breed: breed, contactInfo: contactInfo, address: address, selectedImageData: selectedImageData)
                    } catch {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            }
            .sheet(isPresented: $isShowingMetricsView) {
                // Pass dogOwners and dailyRevenues directly to MetricsDashboardView
                MetricsDashboardView(dogOwners: dogOwners, dailyRevenues: dailyRevenues)
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        } detail: {
            if let selectedDogOwner = selectedDogOwner {
                OwnerProfileView(dogOwner: selectedDogOwner)
            } else {
                Text("Select a dog owner to view details.")
            }
        }
        .onAppear {
            checkForNewDayAndResetRevenue()
        }
    }

    // MARK: - Functions

    // Marked this function as 'throws' because 'modelContext.save()' can throw an error.
    private func addDogOwner(ownerName: String, dogName: String, breed: String, contactInfo: String, address: String, selectedImageData: Data?) throws {
        do {
            // Wrapping 'withAnimation' and 'modelContext.save()' in a single 'do-catch' block
            try withAnimation {
                // Create a new DogOwner instance with the provided details
                let newOwner = DogOwner(
                    ownerName: ownerName,
                    dogName: dogName,
                    breed: breed,
                    contactInfo: contactInfo,
                    address: address,
                    dogImage: selectedImageData, // Use dogImage instead of image
                    notes: "" // Optionally set a default value for notes
                )
                
                // Insert the new DogOwner into the model context
                modelContext.insert(newOwner)
                
                // Save the changes to the context (this can throw, so we use 'try')
                try modelContext.save()
            }
        } catch {
            // Handle any errors during the save process
            throw error // Rethrow the error so the caller can handle it
        }
    }

    private func deleteDogOwners(at offsets: IndexSet) {
        offsets.forEach { index in
            let dogOwner = dogOwners[index]
            modelContext.delete(dogOwner)
        }
        try? modelContext.save()
    }
    
    private func checkForNewDayAndResetRevenue() {
        let currentDate = Date()
        if !Calendar.current.isDate(lastCheckedDate, inSameDayAs: currentDate) {
            lastCheckedDate = currentDate
            // Reset total revenue at the start of a new day
            totalRevenueToday = 0.0
        }
    }
}


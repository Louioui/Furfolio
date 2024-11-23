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
    @Query(FetchDescriptor<DailyRevenue>()) private var dailyRevenues: [DailyRevenue]
    
    @State private var searchText = ""
    @State private var isShowingAddOwnerSheet = false
    @State private var isShowingMetricsView = false
    @State private var selectedDogOwner: DogOwner?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var totalRevenueToday: Double = 0.0
    @State private var lastCheckedDate: Date = Date()

    var body: some View {
        NavigationSplitView {
            List {
                Section(header: Text("Business Insights")) {
                    Button(action: { isShowingMetricsView = true }) {
                        Label("View Metrics Dashboard", systemImage: "chart.bar.xaxis")
                    }
                }

                Section(header: Text("Upcoming Appointments")) {
                    let upcomingAppointments = dogOwners.filter { owner in
                        owner.appointments.contains { appointment in
                            let today = Calendar.current.startOfDay(for: Date())
                            return appointment.date > today && appointment.date < today.addingTimeInterval(7 * 24 * 60 * 60)
                        }
                    }

                    if upcomingAppointments.isEmpty {
                        Text("No upcoming appointments.")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(upcomingAppointments) { owner in
                            if let nextAppointment = owner.appointments.sorted(by: { $0.date < $1.date }).first {
                                NavigationLink {
                                    OwnerProfileView(dogOwner: owner)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(owner.ownerName)
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

                Section(header: Text("Dog Owners")) {
                    let filteredDogOwners = dogOwners.filter { owner in
                        searchText.isEmpty || owner.ownerName.localizedCaseInsensitiveContains(searchText) || owner.dogName.localizedCaseInsensitiveContains(searchText)
                    }

                    if filteredDogOwners.isEmpty {
                        Text("No dog owners found.")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(filteredDogOwners) { owner in
                            NavigationLink {
                                OwnerProfileView(dogOwner: owner)
                            } label: {
                                DogOwnerRowView(dogOwner: owner)
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

    private func addDogOwner(ownerName: String, dogName: String, breed: String, contactInfo: String, address: String, selectedImageData: Data?) throws {
        do {
            try withAnimation {
                let newOwner = DogOwner(ownerName: ownerName, dogName: dogName, breed: breed, contactInfo: contactInfo, address: address, dogImage: selectedImageData)
                modelContext.insert(newOwner)
                try modelContext.save()
            }
        } catch {
            throw error
        }
    }

    private func deleteDogOwners(at offsets: IndexSet) {
        offsets.forEach { index in
            let owner = dogOwners[index]
            modelContext.delete(owner)
        }
        try? modelContext.save()
    }

    private func checkForNewDayAndResetRevenue() {
        let currentDate = Date()
        if !Calendar.current.isDate(lastCheckedDate, inSameDayAs: currentDate) {
            lastCheckedDate = currentDate
            totalRevenueToday = 0.0
        }
    }
}

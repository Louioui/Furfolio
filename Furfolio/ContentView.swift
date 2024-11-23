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
    @State private var dogOwners: [DogOwner] = []
    @State private var dailyRevenues: [DailyRevenue] = []
    @State private var searchText: String = ""
    @State private var isShowingAddOwnerSheet = false
    @State private var isShowingMetricsView = false
    @State private var isAddingAppointment = false
    @State private var isAddingCharge = false
    @State private var selectedDogOwner: DogOwner?
    @State private var errorMessage: String = ""
    @State private var showErrorAlert = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(filteredDogOwners, id: \.id) { owner in
                    Button {
                        selectedDogOwner = owner
                    } label: {
                        DogOwnerRowView(dogOwner: owner)
                    }
                }
                .onDelete(perform: deleteDogOwners)
            }
            .navigationTitle("Furfolio")
            .searchable(text: $searchText)
            .toolbarRole(.navigationStack)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        isShowingAddOwnerSheet = true
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Metrics") {
                        isShowingMetricsView = true
                    }
                }
            }

            .sheet(isPresented: $isShowingAddOwnerSheet) {
                AddDogOwnerView { ownerName, dogName, breed, contactInfo, address, selectedImageData in
                    addDogOwner(ownerName: ownerName, dogName: dogName, breed: breed, contactInfo: contactInfo, address: address, selectedImageData: selectedImageData)
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
                OwnerProfileView(
                    dogOwner: selectedDogOwner,
                    onAddAppointment: { isAddingAppointment = true },
                    onAddCharge: { isAddingCharge = true }
                )
            } else {
                Text("Select a dog owner to view details.")
            }
        }
        .sheet(isPresented: $isAddingAppointment) {
            if let selectedDogOwner = selectedDogOwner {
                AddAppointmentView(dogOwner: selectedDogOwner)
            }
        }
        .sheet(isPresented: $isAddingCharge) {
            if let selectedDogOwner = selectedDogOwner {
                AddChargeView(dogOwner: selectedDogOwner)
            }
        }
        .onAppear {
            loadDogOwners()
            loadDailyRevenues()
        }
    }

    private var filteredDogOwners: [DogOwner] {
        if searchText.isEmpty {
            return dogOwners
        } else {
            return dogOwners.filter {
                $0.ownerName.localizedCaseInsensitiveContains(searchText) ||
                $0.dogName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func loadDogOwners() {
        do {
            dogOwners = try modelContext.fetch(FetchDescriptor<DogOwner>())
        } catch {
            errorMessage = "Failed to fetch Dog Owners: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    private func loadDailyRevenues() {
        do {
            dailyRevenues = try modelContext.fetch(FetchDescriptor<DailyRevenue>())
        } catch {
            errorMessage = "Failed to fetch Daily Revenues: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    private func addDogOwner(ownerName: String, dogName: String, breed: String, contactInfo: String, address: String, selectedImageData: Data?) {
        let newOwner = DogOwner(
            ownerName: ownerName,
            dogName: dogName,
            breed: breed,
            contactInfo: contactInfo,
            address: address,
            dogImage: selectedImageData
        )
        do {
            modelContext.insert(newOwner)
            try modelContext.save()
            loadDogOwners()
        } catch {
            errorMessage = "Failed to save Dog Owner: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    private func deleteDogOwners(at offsets: IndexSet) {
        for index in offsets {
            let owner = dogOwners[index]
            modelContext.delete(owner)
        }
        do {
            try modelContext.save()
            loadDogOwners()
        } catch {
            errorMessage = "Failed to delete Dog Owners: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}


//
//  ContentView.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

// ContentView.swift
import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dogOwners: [DogOwner]

    // For the search functionality
    @State private var searchText = ""
    
    // State variable to show input sheet
    @State private var isShowingAddOwnerSheet = false
    
    // State for selected dog owner
    @State private var selectedDogOwner: DogOwner?

    var body: some View {
        NavigationSplitView {
            // Main List View
            List {
                // Upcoming Appointments Section
                Section(header: Text("Upcoming Appointments")) {
                    ForEach(dogOwners.filter { dogOwner in
                        dogOwner.appointments.contains { appointment in
                            let today = Calendar.current.startOfDay(for: Date())
                            return appointment.date > today && appointment.date < today.addingTimeInterval(7 * 24 * 60 * 60)
                        }
                    }) { dogOwner in
                        NavigationLink {
                            OwnerProfileView(dogOwner: dogOwner)
                        } label: {
                            HStack {
                                Text(dogOwner.ownerName)
                                    .font(.headline)
                                Text("Next Appointment: \(dogOwner.appointments.first?.date.formatted(.dateTime.month().day().year().hour().minute()) ?? "N/A")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }

                // Main Dog Owners Section
                Section(header: Text("Dog Owners")) {
                    ForEach(dogOwners.filter { owner in
                        // Filter dog owners based on search text
                        searchText.isEmpty || owner.ownerName.localizedCaseInsensitiveContains(searchText) || owner.dogName.localizedCaseInsensitiveContains(searchText)
                    }) { dogOwner in
                        NavigationLink {
                            OwnerProfileView(dogOwner: dogOwner)
                        } label: {
                            HStack {
                                // Display image if available, otherwise show a placeholder
                                if let dogImage = dogOwner.dogImage, let uiImage = UIImage(data: dogImage) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }

                                VStack(alignment: .leading) {
                                    Text(dogOwner.ownerName)
                                        .font(.headline)
                                    Text(dogOwner.dogName)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("(\(dogOwner.breed))") // Display breed in the list
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteDogOwners) // Correct place for onDelete
                }
            }
            .navigationTitle("Dog Owners")
            .searchable(text: $searchText) // Search bar at the top
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // "+" button to add new Dog Owner
                    Button(action: {
                        isShowingAddOwnerSheet = true
                    }) {
                        Label("Add Dog Owner", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddOwnerSheet) {
                AddDogOwnerView { ownerName, dogName, breed, contactInfo, address, selectedImageData in
                    addDogOwner(ownerName: ownerName, dogName: dogName, breed: breed, contactInfo: contactInfo, address: address, selectedImageData: selectedImageData)
                }
            }
        } detail: {
            if let selectedDogOwner = selectedDogOwner {
                OwnerProfileView(dogOwner: selectedDogOwner)
            } else {
                Text("Select a dog owner to view charge history.")
            }
        }
    }

    // Add a new Dog Owner with inputted dog and owner name and image data
    private func addDogOwner(ownerName: String, dogName: String, breed: String, contactInfo: String, address: String, selectedImageData: Data?) {
        withAnimation {
            let newOwner = DogOwner(ownerName: ownerName, dogName: dogName, breed: breed, contactInfo: contactInfo, address: address, dogImage: selectedImageData)
            modelContext.insert(newOwner)
        }
    }

    // Delete Dog Owner
    private func deleteDogOwners(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(dogOwners[index])
            }
        }
    }
}

//
//  DogOwnerListView.swift
//  Furfolio
//
//  Created by mac on 11/19/24.
//

import SwiftUI

struct DogOwnerListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dogOwners: [DogOwner] = [] // Assume this is populated from your data model
    @State private var isAddDogOwnerViewPresented = false // To toggle the "Add Dog Owner" view

    var body: some View {
        NavigationView {
            List {
                ForEach(dogOwners) { dogOwner in
                    HStack {
                        // Dog image on the left
                        if let dogImage = dogOwner.dogImage, let uiImage = UIImage(data: dogImage) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        } else {
                            // Placeholder image
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }

                        // Dog owner details
                        VStack(alignment: .leading) {
                            Text(dogOwner.ownerName)
                                .font(.headline)
                            Text(dogOwner.dogName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: deleteDogOwner) // Enable swipe-to-delete functionality
            }
            .navigationTitle("Dog Owners")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isAddDogOwnerViewPresented = true }) {
                        Label("Add Dog Owner", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddDogOwnerViewPresented) {
                AddDogOwnerView { ownerName, dogName, breed, contactInfo, address, imageData in
                    addDogOwner(ownerName: ownerName, dogName: dogName, breed: breed, contactInfo: contactInfo, address: address, imageData: imageData)
                }
            }
        }
    }

    // Add new dog owner to the list and save it
    private func addDogOwner(ownerName: String, dogName: String, breed: String, contactInfo: String, address: String, imageData: Data?) {
        let newDogOwner = DogOwner(ownerName: ownerName, dogName: dogName, breed: breed, contactInfo: contactInfo, address: address, dogImage: imageData)
        dogOwners.append(newDogOwner)
        print("New dog owner added with image data: \(imageData != nil ? "Exists" : "Missing")")
        withAnimation {
            try? modelContext.save() // Save changes to the database
        }
    }

    // Delete a dog owner from the list
    private func deleteDogOwner(at offsets: IndexSet) {
        offsets.forEach { index in
            let dogOwner = dogOwners[index]
            modelContext.delete(dogOwner)
        }
        withAnimation {
            try? modelContext.save() // Save changes to the database
        }
    }
}

//
//  AddDogOwnerView.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//
// AddDogOwnerView.swift
import SwiftUI
import PhotosUI

struct AddDogOwnerView: View {
    var onSave: (String, String, String, String, String, Data?) -> Void // Closure to handle the save action
    @Environment(\.dismiss) private var dismiss

    @State private var ownerName = ""
    @State private var dogName = ""
    @State private var breed = ""
    @State private var contactInfo = ""
    @State private var address = ""
    
    @State private var selectedImageData: Data? // For storing the selected image data
    @State private var selectedItem: PhotosPickerItem? // This will hold the selected photo picker item

    // Computed property to check if all fields are filled
    private var isFormValid: Bool {
        return !ownerName.isEmpty && !dogName.isEmpty && !breed.isEmpty && !contactInfo.isEmpty && !address.isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Owner Details")) {
                    HStack {
                        // Dog image on the left side
                        if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .padding(.trailing, 16)
                        } else {
                            // Default image placeholder if no image is selected
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .padding(.trailing, 16)
                        }

                        // Form fields on the right
                        VStack(alignment: .leading) {
                            TextField("Owner Name", text: $ownerName)
                            TextField("Dog Name", text: $dogName)
                            TextField("Breed", text: $breed)
                            TextField("Contact Info", text: $contactInfo)
                            TextField("Address", text: $address)
                        }
                    }
                }
                
                Section(header: Text("Dog Image")) {
                    PhotosPicker(
                        selection: $selectedItem, // Binding to track the selected photo item
                        matching: .images, // Filter to only images
                        photoLibrary: .shared()) {
                            Text("Select Dog Image")
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                guard let newItem else { return }
                                if let data = try? await newItem.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                    // Optional: Add more fields or description if needed
                }
            }
            .navigationTitle("Add Dog Owner")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if isFormValid {
                            print("Saving Dog Owner with image data: \(selectedImageData != nil ? "Exists" : "Missing")")
                            onSave(ownerName, dogName, breed, contactInfo, address, selectedImageData)
                            dismiss()
                        } else {
                            // Optionally, you can show an alert to the user if the form is invalid
                            print("Please fill out all fields.")
                        }
                    }
                    .disabled(!isFormValid) // Disable save button if form is invalid
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

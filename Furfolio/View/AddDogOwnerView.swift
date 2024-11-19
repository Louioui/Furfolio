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
    var onSave: (String, String, String, String, String, Data?) -> Void // Added Data? for image
    @Environment(\.dismiss) private var dismiss

    @State private var ownerName = ""
    @State private var dogName = ""
    @State private var breed = ""
    @State private var contactInfo = ""
    @State private var address = ""
    
    @State private var selectedImageData: Data? // For storing the selected image data
    @State private var selectedItem: PhotosPickerItem? // This will hold the selected photo picker item

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Owner Details")) {
                    TextField("Owner Name", text: $ownerName)
                    TextField("Dog Name", text: $dogName)
                    TextField("Breed", text: $breed)
                    TextField("Contact Info", text: $contactInfo)
                    TextField("Address", text: $address)
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
                                // Retrieve the selected photo asset's data
                                guard let selectedItem else { return }
                                if let data = try? await selectedItem.loadTransferable(type: Data.self) {
                                    selectedImageData = data // Save the image data
                                }
                            }
                        }

                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }
                }
            }
            .navigationTitle("Add Dog Owner")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(ownerName, dogName, breed, contactInfo, address, selectedImageData)
                        dismiss()
                    }
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


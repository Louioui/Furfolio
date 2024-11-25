//
//  EditDogOwnerView.swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//

import SwiftUI
import PhotosUI

struct EditDogOwnerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ownerName: String
    @State private var dogName: String
    @State private var breed: String
    @State private var contactInfo: String
    @State private var address: String
    @State private var notes: String
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedImageData: Data?
    @State private var isSaving = false
    @State private var showValidationError = false
    @State private var showImageError = false

    var dogOwner: DogOwner
    var onSave: (DogOwner) -> Void

    init(dogOwner: DogOwner, onSave: @escaping (DogOwner) -> Void) {
        _ownerName = State(initialValue: dogOwner.ownerName)
        _dogName = State(initialValue: dogOwner.dogName)
        _breed = State(initialValue: dogOwner.breed)
        _contactInfo = State(initialValue: dogOwner.contactInfo)
        _address = State(initialValue: dogOwner.address)
        _notes = State(initialValue: dogOwner.notes)
        _selectedImageData = State(initialValue: dogOwner.dogImage)

        self.dogOwner = dogOwner
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                // Owner Information Section
                Section(header: Text("Owner Information")) {
                    TextField("Owner Name", text: $ownerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)

                    TextField("Contact Info (Optional)", text: $contactInfo)
                        .keyboardType(.phonePad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Address (Optional)", text: $address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }

                // Dog Information Section
                Section(header: Text("Dog Information")) {
                    TextField("Dog Name", text: $dogName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)

                    TextField("Breed", text: $breed)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)

                    TextField("Notes (Optional)", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.sentences)
                        .onChange(of: notes) { _ in
                            limitNotesLength()
                        }
                }

                // Dog Image Section
                Section(header: Text("Dog Image")) {
                    PhotosPicker(
                        selection: $selectedImage,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                    .accessibilityLabel("Selected dog image")
                            } else {
                                Image(systemName: "photo.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                                    .accessibilityLabel("Default dog image")
                            }
                            Spacer()
                            Text("Select an Image")
                        }
                    }
                    .onChange(of: selectedImage) { newValue in
                        if let newValue {
                            Task {
                                if let data = try? await newValue.loadTransferable(type: Data.self) {
                                    if isValidImage(data: data) {
                                        selectedImageData = data
                                    } else {
                                        showImageError = true
                                    }
                                }
                            }
                        }
                    }
                    .alert("Invalid Image", isPresented: $showImageError) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("Please select an image under 5MB with appropriate dimensions.")
                    }
                }
            }
            .navigationTitle("Edit Dog Owner")
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                // Save Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if validateFields() {
                            isSaving = true
                            let updatedOwner = DogOwner(
                                ownerName: ownerName,
                                dogName: dogName,
                                breed: breed,
                                contactInfo: contactInfo,
                                address: address,
                                dogImage: selectedImageData,
                                notes: notes
                            )
                            onSave(updatedOwner)
                            dismiss()
                        } else {
                            showValidationError = true
                        }
                    }
                    .disabled(isSaving || !validateFields())
                }
            }
            .alert("Missing Required Fields", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please fill out the required fields: Owner Name, Dog Name, and Breed.")
            }
        }
    }

    // MARK: - Validation Methods

    /// Ensures required fields are filled
    private func validateFields() -> Bool {
        !ownerName.isEmpty && !dogName.isEmpty && !breed.isEmpty
    }

    /// Limits the length of the notes to 250 characters
    private func limitNotesLength() {
        if notes.count > 250 {
            notes = String(notes.prefix(250))
        }
    }

    /// Validates the uploaded image for size and dimensions
    private func isValidImage(data: Data) -> Bool {
        let maxSizeMB = 5.0
        let maxSizeBytes = maxSizeMB * 1024 * 1024
        guard data.count <= Int(maxSizeBytes), let image = UIImage(data: data) else { return false }
        return image.size.width > 100 && image.size.height > 100
    }
}



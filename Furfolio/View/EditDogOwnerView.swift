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
                Section(header: Text(NSLocalizedString("Owner Information", comment: "Header for owner information section"))) {
                    TextField(NSLocalizedString("Owner Name", comment: "Placeholder for owner name"), text: $ownerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)

                    TextField(NSLocalizedString("Contact Info (Optional)", comment: "Placeholder for contact information"), text: $contactInfo)
                        .keyboardType(.phonePad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField(NSLocalizedString("Address (Optional)", comment: "Placeholder for address"), text: $address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }

                // Dog Information Section
                Section(header: Text(NSLocalizedString("Dog Information", comment: "Header for dog information section"))) {
                    TextField(NSLocalizedString("Dog Name", comment: "Placeholder for dog name"), text: $dogName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)

                    TextField(NSLocalizedString("Breed", comment: "Placeholder for breed"), text: $breed)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)

                    VStack(alignment: .leading) {
                        TextField(NSLocalizedString("Notes (Optional)", comment: "Placeholder for notes"), text: $notes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.sentences)
                            .onChange(of: notes) { _ in
                                limitNotesLength()
                            }
                        if notes.count > 250 {
                            Text(NSLocalizedString("Notes must be 250 characters or less.", comment: "Warning for note length"))
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }

                // Dog Image Section
                Section(header: Text(NSLocalizedString("Dog Image", comment: "Header for dog image section"))) {
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
                                    .accessibilityLabel(NSLocalizedString("Selected dog image", comment: "Accessibility label for selected dog image"))
                            } else {
                                Image(systemName: "photo.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                                    .accessibilityLabel(NSLocalizedString("Default dog image", comment: "Accessibility label for default dog image"))
                            }
                            Spacer()
                            Text(NSLocalizedString("Select an Image", comment: "Button label for selecting an image"))
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
                    .alert(NSLocalizedString("Invalid Image", comment: "Alert title for invalid image"), isPresented: $showImageError) {
                        Button(NSLocalizedString("OK", comment: "Button label for alert confirmation"), role: .cancel) {}
                    } message: {
                        Text(NSLocalizedString("Please select an image under 5MB with appropriate dimensions.", comment: "Message for invalid image dimensions or size"))
                    }
                }
            }
            .navigationTitle(NSLocalizedString("Edit Dog Owner", comment: "Navigation title for edit dog owner view"))
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("Cancel", comment: "Button label for cancel")) {
                        dismiss()
                    }
                }

                // Save Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Save", comment: "Button label for save")) {
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
            .alert(NSLocalizedString("Missing Required Fields", comment: "Alert title for missing required fields"), isPresented: $showValidationError) {
                Button(NSLocalizedString("OK", comment: "Button label for alert confirmation"), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("Please fill out the required fields: Owner Name, Dog Name, and Breed.", comment: "Message for missing required fields"))
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

//
//  AddDogOwnerView.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

import SwiftUI
import PhotosUI

struct AddDogOwnerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ownerName = ""
    @State private var dogName = ""
    @State private var breed = ""
    @State private var contactInfo = ""
    @State private var address = ""
    @State private var notes = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showErrorAlert = false
    @State private var isSaving = false
    @State private var imageValidationError = false

    var onSave: (String, String, String, String, String, String, Data?) -> Void

    var body: some View {
        NavigationView {
            Form {
                // Owner Information Section
                Section(header: HStack {
                    Image(systemName: "person.fill")
                    Text(NSLocalizedString("Owner Information", comment: "Header for owner information section"))
                }) {
                    TextField(NSLocalizedString("Owner Name", comment: "Placeholder for owner name"), text: $ownerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField(NSLocalizedString("Contact Info (Optional)", comment: "Placeholder for contact information"), text: $contactInfo)
                        .keyboardType(.phonePad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField(NSLocalizedString("Address (Optional)", comment: "Placeholder for address"), text: $address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // Dog Information Section
                Section(header: HStack {
                    Image(systemName: "pawprint.fill")
                    Text(NSLocalizedString("Dog Information", comment: "Header for dog information section"))
                }) {
                    TextField(NSLocalizedString("Dog Name", comment: "Placeholder for dog name"), text: $dogName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField(NSLocalizedString("Breed", comment: "Placeholder for breed"), text: $breed)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

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
                Section(header: HStack {
                    Image(systemName: "photo.fill")
                    Text(NSLocalizedString("Dog Image", comment: "Header for dog image section"))
                }) {
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
                                    .accessibilityLabel(NSLocalizedString("Placeholder dog image", comment: "Accessibility label for placeholder image"))
                            }
                            Spacer()
                            Text(NSLocalizedString("Select an Image", comment: "Label for selecting an image"))
                        }
                    }
                    .onChange(of: selectedImage) { newValue in
                        if let newValue {
                            Task {
                                if let data = try? await newValue.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                    if !isValidImage(data: data) {
                                        imageValidationError = true
                                        selectedImageData = nil
                                    }
                                }
                            }
                        }
                    }
                    .alert(NSLocalizedString("Invalid Image", comment: "Alert title for invalid image"), isPresented: $imageValidationError) {
                        Button(NSLocalizedString("OK", comment: "Button label for dismissing alert"), role: .cancel) {}
                    } message: {
                        Text(NSLocalizedString("Please select an image under 5MB with appropriate dimensions.", comment: "Message for invalid image size or dimensions"))
                    }
                }
            }
            .navigationTitle(NSLocalizedString("Add Dog Owner", comment: "Navigation title for Add Dog Owner view"))
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
                            onSave(ownerName, dogName, breed, contactInfo, address, notes, selectedImageData)
                            dismiss()
                        } else {
                            showErrorAlert = true
                        }
                    }
                    .disabled(isSaving || !validateFields())
                }
            }
            .alert(NSLocalizedString("Missing Required Fields", comment: "Alert title for missing required fields"), isPresented: $showErrorAlert) {
                Button(NSLocalizedString("OK", comment: "Button label for dismissing alert"), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("Please fill out the required fields: Owner Name, Dog Name, and Breed.", comment: "Message for missing required fields"))
            }
        }
    }

    // MARK: - Validation Methods

    /// Validates that the required fields are not empty
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

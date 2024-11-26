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
                Section(header: Text("Owner Information")) {
                    TextField("Owner Name", text: $ownerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Contact Info (Optional)", text: $contactInfo)
                        .keyboardType(.phonePad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Address (Optional)", text: $address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // Dog Information Section
                Section(header: Text("Dog Information")) {
                    TextField("Dog Name", text: $dogName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Breed", text: $breed)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    VStack(alignment: .leading) {
                        TextField("Notes (Optional)", text: $notes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.sentences)
                            .onChange(of: notes) { _ in
                                limitNotesLength()
                            }
                        if notes.count > 250 {
                            Text("Notes must be 250 characters or less.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
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
                                    .accessibilityLabel("Placeholder dog image")
                            }
                            Spacer()
                            Text("Select an Image")
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
                    .alert("Invalid Image", isPresented: $imageValidationError) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("Please select an image under 5MB with appropriate dimensions.")
                    }
                }
            }
            .navigationTitle("Add Dog Owner")
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
                            onSave(ownerName, dogName, breed, contactInfo, address, notes, selectedImageData)
                            dismiss()
                        } else {
                            showErrorAlert = true
                        }
                    }
                    .disabled(isSaving || !validateFields())
                }
            }
            .alert("Missing Required Fields", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please fill out the required fields: Owner Name, Dog Name, and Breed.")
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


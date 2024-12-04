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

    // Health Record state
    @State private var healthCondition: String = ""
    @State private var treatment: String = ""
    @State private var healthNotes: String = ""

    // Behavior Tags state
    @State private var behaviorTags: [String] = [] // Behavior tags array
    @State private var behaviorTagsString: String = "" // String for new tag entry

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
                ownerInformationSection()
                dogInformationSection()
                dogImageSection()
                healthRecordSection() // Health Record section added
                behaviorTagsSection() // Behavior Tags section added
            }
            .navigationTitle("Edit Dog Owner")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        handleSave()
                    }
                    .disabled(isSaving || !validateFields())
                }
            }
            .alert("Missing Required Fields", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please fill out the required fields: Owner Name, Dog Name, and Breed.")
            }
            .alert("Invalid Image", isPresented: $showImageError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please select an image under 5MB with appropriate dimensions.")
            }
        }
    }

    // MARK: - Form Sections

    private func ownerInformationSection() -> some View {
        Section(header: Text("Owner Information")) {
            customTextField(placeholder: "Owner Name", text: $ownerName)
            customTextField(placeholder: "Contact Info (Optional)", text: $contactInfo, keyboardType: .phonePad)
            customTextField(placeholder: "Address (Optional)", text: $address)
        }
    }

    private func dogInformationSection() -> some View {
        Section(header: Text("Dog Information")) {
            customTextField(placeholder: "Dog Name", text: $dogName)
            customTextField(placeholder: "Breed", text: $breed)
            notesField()
        }
    }

    private func dogImageSection() -> some View {
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
            .onChange(of: selectedImage) { newValue in handleImageSelection(newValue) }
        }
    }

    private func healthRecordSection() -> some View {
        Section(header: Text("Health Record")) {
            customTextField(placeholder: "Health Condition", text: $healthCondition)
            customTextField(placeholder: "Treatment", text: $treatment)
            customTextField(placeholder: "Health Notes (Optional)", text: $healthNotes)
        }
    }

    private func behaviorTagsSection() -> some View {
        Section(header: Text("Behavior Tags")) {
            TextField("Enter Behavior Tag", text: $behaviorTagsString)
                .onSubmit {
                    if !behaviorTags.contains(behaviorTagsString) {
                        behaviorTags.append(behaviorTagsString)
                    }
                    behaviorTagsString = "" // Reset text after submitting
                }
            List(behaviorTags, id: \.self) { tag in
                Text(tag)
            }
        }
    }

    private func notesField() -> some View {
        VStack(alignment: .leading) {
            customTextField(placeholder: "Notes (Optional)", text: $notes)
                .onChange(of: notes) { _ in limitNotesLength() }
            
            if notes.count > 250 {
                Text("Notes must be 250 characters or less.")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private func customTextField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(keyboardType)
            .autocapitalization(.words)
    }

    // MARK: - Save Handling

    private func handleSave() {
        if validateFields() {
            isSaving = true
            updateDogOwner()
            dismiss()
        } else {
            showValidationError = true
        }
    }

    /// Updates the `DogOwner` object and calls the `onSave` closure
    private func updateDogOwner() {
        dogOwner.ownerName = ownerName
        dogOwner.dogName = dogName
        dogOwner.breed = breed
        dogOwner.contactInfo = contactInfo
        dogOwner.address = address
        dogOwner.notes = notes
        dogOwner.dogImage = selectedImageData
        dogOwner.healthRecords.append(HealthRecord(dogOwner: dogOwner, date: Date(), healthCondition: healthCondition, treatment: treatment, notes: healthNotes)) // Add the health record
        dogOwner.behaviorTags = behaviorTags // Save the behavior tags
        onSave(dogOwner)
    }

    // MARK: - Helper Methods

    private func handleImageSelection(_ newValue: PhotosPickerItem?) {
        Task {
            if let newValue, let data = try? await newValue.loadTransferable(type: Data.self) {
                if isValidImage(data: data) {
                    selectedImageData = data
                } else {
                    showImageError = true
                }
            }
        }
    }

    private func validateFields() -> Bool {
        !ownerName.isEmpty && !dogName.isEmpty && !breed.isEmpty
    }

    private func limitNotesLength() {
        if notes.count > 250 {
            notes = String(notes.prefix(250))
        }
    }

    private func isValidImage(data: Data) -> Bool {
        let maxSizeMB = 5.0
        let maxSizeBytes = maxSizeMB * 1024 * 1024
        guard data.count <= Int(maxSizeBytes), let image = UIImage(data: data) else { return false }
        return image.size.width > 100 && image.size.height > 100
    }
}

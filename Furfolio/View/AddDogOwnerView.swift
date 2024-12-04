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
    @State private var imageValidationError = false
    @State private var isSaving = false
    @State private var dogBirthdate: Date = Date() // Non-optional date with default value
    @State private var age: Int? = nil

    // Health Record Fields
    @State private var healthCondition = ""
    @State private var treatment = ""
    @State private var healthNotes = ""

    // Behavior Tags Field
    @State private var behaviorTags: [String] = []  // Array to store behavior tags
    @State private var behaviorTagsString: String = "" // String to capture input for tags

    var onSave: (String, String, String, String, String, String, Data?, Date?, String, String, String, [String]) -> Void

    var body: some View {
        NavigationView {
            Form {
                ownerInformationSection()
                dogInformationSection()
                dogAgeSection()
                dogImageSection()
                healthRecordSection() // New Section for Health Record
                behaviorTagsSection() // New Section for Behavior Tags
            }
            .navigationTitle(NSLocalizedString("Add Dog Owner", comment: "Navigation title for Add Dog Owner view"))
            .toolbar {
                toolbarContent()
            }
            .alert(
                NSLocalizedString("Missing Required Fields", comment: "Alert title for missing required fields"),
                isPresented: $showErrorAlert
            ) {
                Button(NSLocalizedString("OK", comment: "Button label for dismissing alert"), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("Please fill out the required fields: Owner Name, Dog Name, and Breed.", comment: "Message for missing required fields"))
            }
        }
    }

    // MARK: - Form Sections

    @ViewBuilder
    private func ownerInformationSection() -> some View {
        Section(header: sectionHeader(icon: "person.fill", title: "Owner Information")) {
            customTextField(placeholder: "Owner Name", text: $ownerName)
            customTextField(placeholder: "Contact Info (Optional)", text: $contactInfo, keyboardType: .phonePad)
            customTextField(placeholder: "Address (Optional)", text: $address)
        }
    }

    @ViewBuilder
    private func dogInformationSection() -> some View {
        Section(header: sectionHeader(icon: "pawprint.fill", title: "Dog Information")) {
            customTextField(placeholder: "Dog Name", text: $dogName)
            customTextField(placeholder: "Breed", text: $breed)
            notesField()
        }
    }

    @ViewBuilder
    private func dogAgeSection() -> some View {
        Section(header: sectionHeader(icon: "calendar.fill", title: "Dog Age")) {
            DatePicker("Dog Birthdate", selection: $dogBirthdate, displayedComponents: .date)
                .onChange(of: dogBirthdate) { newValue in
                    age = calculateAge(from: newValue)
                }
            if let age = age {
                Text("Dog Age: \(age) years")
            } else {
                Text("Select a birthdate to calculate the dog's age")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    @ViewBuilder
    private func notesField() -> some View {
        VStack(alignment: .leading) {
            customTextField(placeholder: "Notes (Optional)", text: $notes)
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

    @ViewBuilder
    private func dogImageSection() -> some View {
        Section(header: sectionHeader(icon: "photo.fill", title: "Dog Image")) {
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
                handleImageSelection(newValue)
            }
            .alert(NSLocalizedString("Invalid Image", comment: "Alert title for invalid image"), isPresented: $imageValidationError) {
                Button(NSLocalizedString("OK", comment: "Button label for dismissing alert"), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("Please select an image under 5MB with appropriate dimensions.", comment: "Message for invalid image size or dimensions"))
            }
        }
    }

    // MARK: - Health Record Section (New Section)

    @ViewBuilder
    private func healthRecordSection() -> some View {
        Section(header: sectionHeader(icon: "heart.fill", title: "Health Record")) {
            customTextField(placeholder: "Health Condition", text: $healthCondition)
            customTextField(placeholder: "Treatment", text: $treatment)
            customTextField(placeholder: "Health Notes (Optional)", text: $healthNotes)
        }
    }

    // MARK: - Behavior Tags Section (New Section)

    @ViewBuilder
    private func behaviorTagsSection() -> some View {
        Section(header: sectionHeader(icon: "tag.fill", title: "Behavior Tags")) {
            TextField("Enter Behavior Tags", text: $behaviorTagsString)
                .onSubmit {
                    if !behaviorTags.contains(behaviorTagsString) {
                        behaviorTags.append(behaviorTagsString)
                    }
                    behaviorTagsString = "" // Reset the text field
                }
            List(behaviorTags, id: \.self) { tag in
                Text(tag)
            }
        }
    }

    // MARK: - Toolbar Content

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(NSLocalizedString("Cancel", comment: "Button label for cancel")) {
                dismiss()
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button(NSLocalizedString("Save", comment: "Button label for save")) {
                handleSave()
            }
            .disabled(isSaving || !validateFields())
        }
    }

    // MARK: - Utility Methods

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(NSLocalizedString(title, comment: "Section header"))
        }
    }

    /// Custom text field component for reusability
    private func customTextField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(NSLocalizedString(placeholder, comment: "Placeholder for \(placeholder)"), text: text)
            .keyboardType(keyboardType)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }

    /// Handles saving the entered data
    private func handleSave() {
        if validateFields() {
            isSaving = true
            onSave(ownerName, dogName, breed, contactInfo, address, notes, selectedImageData, dogBirthdate, healthCondition, treatment, healthNotes, behaviorTags) // Save behavior tags
            dismiss()
        } else {
            showErrorAlert = true
        }
    }

    /// Handles image selection and validation
    private func handleImageSelection(_ newValue: PhotosPickerItem?) {
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

    /// Calculate dog's age from the birthdate
    private func calculateAge(from birthdate: Date?) -> Int? {
        guard let birthdate = birthdate else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: Date())
        return ageComponents.year
    }
}

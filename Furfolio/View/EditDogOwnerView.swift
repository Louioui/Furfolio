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
                Section(header: Text("Owner Information")) {
                    TextField("Owner Name", text: $ownerName)
                    TextField("Contact Info", text: $contactInfo)
                    TextField("Address", text: $address)
                }

                Section(header: Text("Dog Information")) {
                    TextField("Dog Name", text: $dogName)
                    TextField("Breed", text: $breed)
                    TextField("Notes", text: $notes)
                }

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
                            } else {
                                Image(systemName: "photo.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
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
                                }
                            }
                        }
                    }
                }
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
                    }
                    .disabled(ownerName.isEmpty || dogName.isEmpty || breed.isEmpty)
                }
            }
        }
    }
}

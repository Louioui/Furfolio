//
//  AddDogOwnerView.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//
// AddDogOwnerView.swift
// AddDogOwnerView.swift
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

    var onSave: (String, String, String, String, String, Data?) -> Void

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
            .navigationTitle("Add Dog Owner")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(ownerName, dogName, breed, contactInfo, address, selectedImageData)
                        dismiss()
                    }
                    .disabled(ownerName.isEmpty || dogName.isEmpty || breed.isEmpty)
                }
            }
        }
    }
}

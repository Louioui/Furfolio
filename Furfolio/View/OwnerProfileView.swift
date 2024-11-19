import SwiftUI
import PhotosUI

struct OwnerProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dogOwner: DogOwner
    @State private var selectedItem: PhotosPickerItem? // This will hold the selected photo item
    @State private var selectedImageData: Data? // To store selected image data for update
    @State private var isImagePickerPresented = false // To manage photo picker sheet presentation

    init(dogOwner: DogOwner) {
        self._dogOwner = State(initialValue: dogOwner)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Display the image if available
            if let dogImage = dogOwner.dogImage, let uiImage = UIImage(data: dogImage) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                // Default image if no image is provided
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            
            HStack {
                Button("Delete Image") {
                    removeImage()
                }
                .foregroundColor(.red)
                
                Button("Update Image") {
                    // Toggle photo picker presentation
                    isImagePickerPresented.toggle()
                }
                .foregroundColor(.blue)
            }

            Text("Owner Name: \(dogOwner.ownerName)")
                .font(.title2)
            Text("Dog Name: \(dogOwner.dogName)")
                .font(.headline)
            Text("Breed: \(dogOwner.breed)")
                .font(.subheadline)
            Text("Contact Info: \(dogOwner.contactInfo)")
                .font(.subheadline)
            Text("Address: \(dogOwner.address)")
                .font(.subheadline)

            Divider()
            Text("Appointment Schedule")
                .font(.headline)
            List(dogOwner.appointments) { appointment in
                VStack(alignment: .leading) {
                    Text("Date: \(appointment.date.formatted(.dateTime.month().day().year().hour().minute())) - Service: \(appointment.serviceType)")
                        .font(.subheadline)
                        .foregroundColor(appointment.status == .overdue ? .red : .blue)
                    Text("Status: \(appointment.status.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(appointment.status == .completed ? .green : .gray)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .navigationTitle("\(dogOwner.ownerName)'s Profile")
        .sheet(isPresented: $isImagePickerPresented) {
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
                            updateImage(with: selectedImageData!)
                        }
                    }
                }
        }
    }

    private func removeImage() {
        dogOwner.dogImage = nil
        saveChanges() // To save the updated model
    }

    private func updateImage(with newImageData: Data) {
        dogOwner.dogImage = newImageData
        saveChanges() // To save the updated model
    }

    private func saveChanges() {
        withAnimation {
            try? modelContext.save() // Save changes to the context
        }
    }
}


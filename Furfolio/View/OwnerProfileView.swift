//OwnerProfileView.swift

import SwiftUI
import PhotosUI

struct OwnerProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dogOwner: DogOwner
    @State private var notes: String

    init(dogOwner: DogOwner) {
        self._dogOwner = State(initialValue: dogOwner)
        self._notes = State(initialValue: dogOwner.notes ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if let dogImage = dogOwner.dogImage, let uiImage = UIImage(data: dogImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading) {
                    Text(dogOwner.ownerName)
                        .font(.title2)
                    Text(dogOwner.dogName)
                        .font(.headline)
                    Text(dogOwner.breed)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Notes Section
            TextField("Notes", text: $notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 120)
                .onChange(of: notes) { newNotes in
                    dogOwner.notes = newNotes // Update notes
                    withAnimation {
                        try? modelContext.save()
                    }
                }
        }
        .padding()
        .navigationTitle("Owner Profile")
    }
}


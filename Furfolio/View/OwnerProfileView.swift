//
//  OwnerProfileView.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//


import SwiftUI

struct OwnerProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State var dogOwner: DogOwner
    @State private var editedNotes: String // To track the edited note
    
    // Initialize with the dog's existing notes
    init(dogOwner: DogOwner) {
        self._dogOwner = State(initialValue: dogOwner)
        self._editedNotes = State(initialValue: dogOwner.notes) // Initialize the notes for editing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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

            // Editable Notes Section
            Section(header: Text("Notes")) {
                TextEditor(text: $editedNotes)
                    .frame(height: 150)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .border(Color.gray, width: 1)
                    .padding(.bottom)

                HStack {
                    Button("Save Notes") {
                        // Save changes to the dog owner's notes
                        dogOwner.notes = editedNotes
                        saveChanges()
                    }
                    .padding(.top)

                    Spacer()

                    // Add a button to clear the notes
                    Button("Clear Notes") {
                        // If the user wants to clear the notes
                        editedNotes = "" // Reset the notes text
                        dogOwner.notes = "" // Clear the note from the model
                        saveChanges()
                    }
                    .foregroundColor(.red)
                    .padding(.top)
                }
            }

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
    }

    private func saveChanges() {
        do {
            try modelContext.save() // Save the updated dog owner with the new notes
        } catch {
            // Handle the error (for example, show an alert or log the error)
            print("Failed to save changes: \(error.localizedDescription)")
        }
    }

}

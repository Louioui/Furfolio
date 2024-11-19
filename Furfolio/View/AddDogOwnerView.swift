//
//  AddDogOwnerView.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

import SwiftUI

struct AddDogOwnerView: View {
    var onSave: (String, String, String, String, String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var ownerName = ""
    @State private var dogName = ""
    @State private var breed = ""
    @State private var contactInfo = ""
    @State private var address = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Owner Details")) {
                    TextField("Owner Name", text: $ownerName)
                    TextField("Dog Name", text: $dogName)
                    TextField("Breed", text: $breed)
                    TextField("Contact Info", text: $contactInfo)
                    TextField("Address", text: $address)
                }
            }
            .navigationTitle("Add Dog Owner")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(ownerName, dogName, breed, contactInfo, address)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

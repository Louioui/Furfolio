//
//  AddHealthRecordView.swift
//  Furfolio
//
//  Created by mac on 12/1/24.
//

import SwiftUI

struct AddHealthRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var healthCondition: String = ""
    @State private var treatment: String = ""
    @State private var healthNotes: String = ""
    @State private var isSaving: Bool = false

    let dogOwner: DogOwner
    let onSave: (HealthRecord) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Health Condition")) {
                    TextField("Enter health condition", text: $healthCondition)
                }
                Section(header: Text("Treatment")) {
                    TextField("Enter treatment details", text: $treatment)
                }
                Section(header: Text("Notes (Optional)")) {
                    TextField("Enter any additional notes", text: $healthNotes)
                }
            }
            .navigationTitle("Add Health Record")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHealthRecord()
                    }
                    .disabled(isSaving || healthCondition.isEmpty || treatment.isEmpty)
                }
            }
        }
    }

    private func saveHealthRecord() {
        isSaving = true

        let newHealthRecord = HealthRecord(
            dogOwner: dogOwner,
            date: Date(),
            healthCondition: healthCondition,
            treatment: treatment,
            notes: healthNotes
        )

        onSave(newHealthRecord)
        dismiss()
    }
}

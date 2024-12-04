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
    
    // Behavior Tags
    @State private var behaviorTags: [String] = []  // Array to store behavior tags
    @State private var behaviorTagsString: String = "" // String to capture input for tags

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

                // Behavior Tags Section
                Section(header: Text("Behavior Tags (Optional)")) {
                    TextField("Enter behavior tags", text: $behaviorTagsString)
                        .onSubmit {
                            if !behaviorTags.contains(behaviorTagsString) {
                                behaviorTags.append(behaviorTagsString)
                            }
                            behaviorTagsString = "" // Reset the text field after submission
                        }
                    List(behaviorTags, id: \.self) { tag in
                        Text(tag)
                    }
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
            notes: healthNotes,
            behaviorTags: behaviorTags // Include behavior tags when saving
        )

        onSave(newHealthRecord)
        dismiss()
    }
}

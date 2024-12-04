//
//  AddChargeView.swift
//  Furfolio
//
//  Created by mac on 11/19/24.
//

import SwiftUI

struct AddChargeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let dogOwner: DogOwner

    @State private var serviceType: ChargeType = .basic
    @State private var chargeAmount: Double? = nil
    @State private var chargeNotes = ""
    @State private var behaviorTags: [String] = []  // New behavior tags array for advanced behavior tracking
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSaving = false

    var body: some View {
        NavigationView {
            Form {
                chargeInformationSection()
            }
            .navigationTitle(NSLocalizedString("Add Charge", comment: "Navigation title for Add Charge view"))
            .toolbar {
                toolbarContent()
            }
            .alert(
                NSLocalizedString("Invalid Charge", comment: "Alert title for invalid charge"),
                isPresented: $showErrorAlert
            ) {
                Button(NSLocalizedString("OK", comment: "OK button label"), role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private func chargeInformationSection() -> some View {
        Section(header: Text(NSLocalizedString("Charge Information", comment: "Header for charge information section"))) {
            serviceTypePicker()
            chargeAmountInput()
            notesField()
            behaviorTagsField() // New section for behavior tags
        }
    }

    @ViewBuilder
    private func serviceTypePicker() -> some View {
        Picker(
            NSLocalizedString("Service Type", comment: "Picker label for service type"),
            selection: $serviceType
        ) {
            ForEach(ChargeType.allCases, id: \.self) { type in
                Text(type.localized)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    @ViewBuilder
    private func chargeAmountInput() -> some View {
        TextField(
            NSLocalizedString("Amount Charged", comment: "Text field label for charge amount"),
            value: $chargeAmount,
            format: .currency(code: Locale.current.currency?.identifier ?? "USD")
        )
        .keyboardType(.decimalPad)
        .onChange(of: chargeAmount) { newValue in
            if let newValue = newValue {
                chargeAmount = max(newValue, 0.0) // Ensure non-negative
            }
        }
    }

    @ViewBuilder
    private func notesField() -> some View {
        VStack(alignment: .leading) {
            TextField(
                NSLocalizedString("Additional Notes (Optional)", comment: "Text field label for additional notes"),
                text: $chargeNotes
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.sentences)
            .onChange(of: chargeNotes) { _ in
                limitNotesLength()
            }

            if chargeNotes.count > 250 {
                Text(NSLocalizedString("Notes must be 250 characters or less.", comment: "Warning for note length"))
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    @ViewBuilder
    private func behaviorTagsField() -> some View {
        VStack(alignment: .leading) {
            TextField(
                NSLocalizedString("Behavior Tags (Optional)", comment: "Text field label for behavior tags"),
                text: Binding(
                    get: { behaviorTags.joined(separator: ", ") },
                    set: { behaviorTags = $0.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) } }
                )
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.sentences)

            if behaviorTags.isEmpty == false {
                Text("Behavior tags: \(behaviorTags.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(NSLocalizedString("Cancel", comment: "Cancel button label")) {
                dismiss()
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button(NSLocalizedString("Save", comment: "Save button label")) {
                handleSave()
            }
            .disabled(!isFormValid() || isSaving)
        }
    }

    // MARK: - Save Handling

    private func handleSave() {
        if validateCharge() {
            isSaving = true
            saveChargeHistory()
            dismiss()
        } else {
            showErrorAlert = true
        }
    }

    /// Saves the charge entry to the model context
    private func saveChargeHistory() {
        let newCharge = Charge(
            date: Date(),
            type: Charge.ServiceType(rawValue: serviceType.rawValue) ?? .custom,
            amount: chargeAmount ?? 0.0,
            dogOwner: dogOwner,
            notes: chargeNotes,
            behavioralTags: behaviorTags // Change 'behaviorTags' to 'behavioralTags'
        )

        withAnimation {
            modelContext.insert(newCharge)
            dogOwner.charges.append(newCharge)
        }
    }
    // MARK: - Validation Methods

    /// Validates the charge and checks for errors
    private func validateCharge() -> Bool {
        guard let amount = chargeAmount, amount > 0.0 else {
            errorMessage = NSLocalizedString("Charge amount must be greater than 0.", comment: "Error message for zero or negative charge amount")
            return false
        }

        if serviceType.rawValue.isEmpty {
            errorMessage = NSLocalizedString("Please select a valid service type.", comment: "Error message for unselected service type")
            return false
        }

        return true
    }

    /// Checks if the form is valid for enabling the "Save" button
    private func isFormValid() -> Bool {
        guard let amount = chargeAmount else { return false }
        return amount > 0.0 && !serviceType.rawValue.isEmpty
    }

    /// Limits the length of the notes to 250 characters
    private func limitNotesLength() {
        if chargeNotes.count > 250 {
            chargeNotes = String(chargeNotes.prefix(250))
        }
    }
}

// MARK: - ChargeType Enum

/// Enum for predefined charge types
enum ChargeType: String, CaseIterable {
    case basic = "Basic Package"
    case full = "Full Package"
    case custom = "Custom Service"

    var localized: String {
        NSLocalizedString(self.rawValue, comment: "Localized description of \(self.rawValue)")
    }
}

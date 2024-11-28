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
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSaving = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("Charge Information", comment: "Header for charge information section"))) {
                    // Service Type Picker
                    Picker(NSLocalizedString("Service Type", comment: "Picker label for service type"), selection: $serviceType) {
                        ForEach(ChargeType.allCases, id: \.self) { type in
                            Text(type.localized)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    // Charge Amount Input
                    TextField(NSLocalizedString("Amount Charged", comment: "Text field label for charge amount"), value: $chargeAmount, format: .currency(code: Locale.current.currencyCode ?? "USD"))
                        .keyboardType(.decimalPad)
                        .onChange(of: chargeAmount) { newValue in
                            if let newValue {
                                chargeAmount = max(newValue, 0.0) // Ensure non-negative
                            }
                        }

                    // Notes Field
                    VStack(alignment: .leading) {
                        TextField(NSLocalizedString("Additional Notes (Optional)", comment: "Text field label for additional notes"), text: $chargeNotes)
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
            }
            .navigationTitle(NSLocalizedString("Add Charge", comment: "Navigation title for Add Charge view"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("Cancel", comment: "Cancel button label")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Save", comment: "Save button label")) {
                        if validateCharge() {
                            isSaving = true
                            saveChargeHistory()
                            dismiss()
                        } else {
                            showErrorAlert = true
                        }
                    }
                    .disabled(!isFormValid() || isSaving)
                }
            }
            .alert(NSLocalizedString("Invalid Charge", comment: "Alert title for invalid charge"), isPresented: $showErrorAlert) {
                Button(NSLocalizedString("OK", comment: "OK button label"), role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Validation Methods

    /// Validates the charge and checks for errors
    private func validateCharge() -> Bool {
        if let amount = chargeAmount, amount <= 0.0 {
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

    // MARK: - Save Method

    /// Saves the charge entry to the model context
    private func saveChargeHistory() {
        let newCharge = Charge(
            date: Date(),
            type: Charge.ServiceType(rawValue: serviceType.rawValue) ?? .custom,
            amount: chargeAmount ?? 0.0,
            dogOwner: dogOwner,
            notes: chargeNotes
        )
        withAnimation {
            modelContext.insert(newCharge)
            dogOwner.charges.append(newCharge)
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
        NSLocalizedString(self.rawValue, comment: "")
    }
}

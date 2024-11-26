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
                Section(header: Text("Charge Information")) {
                    // Service Type Picker
                    Picker("Service Type", selection: $serviceType) {
                        ForEach(ChargeType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    // Charge Amount Input
                    TextField("Amount Charged", value: $chargeAmount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .onChange(of: chargeAmount) { newValue in
                            if let newValue {
                                chargeAmount = max(newValue, 0.0) // Ensure non-negative
                            }
                        }

                    // Notes Field
                    VStack(alignment: .leading) {
                        TextField("Additional Notes (Optional)", text: $chargeNotes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.sentences)
                            .onChange(of: chargeNotes) { _ in
                                limitNotesLength()
                            }
                        if chargeNotes.count > 250 {
                            Text("Notes must be 250 characters or less.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Add Charge")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
            .alert("Invalid Charge", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Validation Methods

    /// Validates the charge and checks for errors
    private func validateCharge() -> Bool {
        if let amount = chargeAmount, amount <= 0.0 {
            errorMessage = "Charge amount must be greater than 0."
            return false
        }
        if serviceType.rawValue.isEmpty {
            errorMessage = "Please select a valid service type."
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
}


//
//  AddChargeView.swift
//  Furfolio
//
//  Created by mac on 11/19/24.
import SwiftUI

struct AddChargeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let dogOwner: DogOwner

    @State private var serviceType = "Basic Package"  // Type of service provided
    @State private var chargeAmount = 0.0  // Amount charged for the service
    @State private var chargeNotes = ""  // Any additional notes about the charge

    let serviceTypes = ["Basic Package", "Full Package", "Custom Service"]

    var body: some View {
        NavigationView {
            Form {
                // Correctly structured Section
                Section {
                    Picker("Service Type", selection: $serviceType) {
                        ForEach(serviceTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    TextField("Amount Charged", value: $chargeAmount, formatter: NumberFormatter.currency)
                        .keyboardType(.decimalPad)
                        .onChange(of: chargeAmount) { newValue in
                            chargeAmount = max(newValue, 0.0)  // Ensure chargeAmount is non-negative
                        }

                    TextField("Additional Notes", text: $chargeNotes)
                } header: {
                    Text("Charge Information")  // This is now correct with a closure for header
                }
            }
            .navigationTitle("Input Charge Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChargeHistory()  // Save the charge details
                        dismiss()
                    }
                    .disabled(chargeAmount <= 0.0)  // Disable save if charge amount is zero or negative
                }
            }
        }
    }

    private func saveChargeHistory() {
        // Create a new charge entry with the input details
        let newCharge = Charge(date: Date(), type: serviceType, amount: chargeAmount, dogOwner: dogOwner)
        modelContext.insert(newCharge)  // Insert the charge into the database
        dogOwner.charges.append(newCharge)  // Optionally append locally to dogOwner for UI update
    }
}

extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter
    }
}

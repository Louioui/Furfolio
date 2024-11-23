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

    @State private var serviceType = "Basic Package"
    @State private var chargeAmount = 0.0
    @State private var chargeNotes = ""

    let serviceTypes = ["Basic Package", "Full Package", "Custom Service"]

    var body: some View {
        NavigationView {
            Form {
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
                            chargeAmount = max(newValue, 0.0) // Ensure non-negative charges
                        }

                    TextField("Additional Notes", text: $chargeNotes)
                } header: {
                    Text("Charge Information")
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
                        saveChargeHistory()
                        dismiss()
                    }
                    .disabled(chargeAmount <= 0.0) // Prevent saving invalid charges
                }
            }
        }
    }

    private func saveChargeHistory() {
        let newCharge = Charge(date: Date(), type: serviceType, amount: chargeAmount, dogOwner: dogOwner, notes: chargeNotes)
        modelContext.insert(newCharge)
        dogOwner.charges.append(newCharge)
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

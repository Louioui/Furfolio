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
                Section(header: Text("Charge Information")) {
                    Picker("Service Type", selection: $serviceType) {
                        ForEach(serviceTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    TextField("Amount Charged", value: $chargeAmount, formatter: NumberFormatter.currency)
                        .keyboardType(.decimalPad)
                    TextField("Additional Notes", text: $chargeNotes)
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
                        saveCharge()
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveCharge() {
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

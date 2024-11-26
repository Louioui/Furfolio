//
//  Charge.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

import Foundation
import SwiftData

@Model
final class Charge: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var type: ServiceType // Enum for service types
    var amount: Double
    @Relationship(deleteRule: .nullify) var dogOwner: DogOwner
    var notes: String?

    // Enum to define service types
    enum ServiceType: String, Codable, CaseIterable {
        case basic = "Basic Package"
        case full = "Full Package"
        case custom = "Custom Package"
    }

    // MARK: - Initializer
    init(date: Date, type: ServiceType, amount: Double, dogOwner: DogOwner, notes: String? = nil) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.amount = max(0, amount) // Ensure no negative amount
        self.dogOwner = dogOwner
        self.notes = notes
    }

    // MARK: - Computed Properties

    /// Format the charge amount as currency
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }

    /// Format the charge date for display
    var formattedDate: String {
        date.formatted(.dateTime.month().day().year())
    }

    /// Validation to ensure the charge is valid
    var isValid: Bool {
        amount > 0 && !type.rawValue.isEmpty
    }

    /// Check if the charge is overdue
    var isOverdue: Bool {
        date < Date()
    }

    // MARK: - Methods

    /// Check if a charge belongs to a specific month and year
    func isInMonth(_ month: Int, year: Int) -> Bool {
        let calendar = Calendar.current
        let chargeMonth = calendar.component(.month, from: date)
        let chargeYear = calendar.component(.year, from: date)
        return chargeMonth == month && chargeYear == year
    }

    /// Apply a discount to the charge
    func applyDiscount(_ percentage: Double) {
        guard percentage > 0 && percentage <= 100 else { return }
        amount -= amount * (percentage / 100)
    }

    // MARK: - Static Methods

    /// Calculate total amounts grouped by charge type
    static func totalByType(charges: [Charge]) -> [ServiceType: Double] {
        var totals = [ServiceType: Double]()
        for charge in charges {
            totals[charge.type, default: 0] += charge.amount
        }
        return totals
    }

    /// Calculate the total revenue for a given month and year
    static func totalRevenue(forMonth month: Int, year: Int, charges: [Charge]) -> Double {
        charges.filter { $0.isInMonth(month, year: year) }.reduce(0) { $0 + $1.amount }
    }

    /// Filter charges based on a specific dog owner
    static func chargesForOwner(_ owner: DogOwner, from charges: [Charge]) -> [Charge] {
        charges.filter { $0.dogOwner.id == owner.id }
    }

    /// Get overdue charges from a list
    static func overdueCharges(from charges: [Charge]) -> [Charge] {
        charges.filter { $0.isOverdue }
    }

    /// Categorize charges by service type
    static func categorizeByType(_ charges: [Charge]) -> [ServiceType: [Charge]] {
        var categorized = [ServiceType: [Charge]]()
        for charge in charges {
            categorized[charge.type, default: []].append(charge)
        }
        return categorized
    }
}


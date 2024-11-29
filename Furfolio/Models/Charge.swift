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
    var petBadges: [String] // Track badges associated with this charge (e.g., behavior notes)

    // Enum to define service types with localization support
    enum ServiceType: String, Codable, CaseIterable {
        case basic = "Basic Package"
        case full = "Full Package"
        case custom = "Custom Package"

        var localized: String {
            NSLocalizedString(self.rawValue, comment: "Localized description of \(self.rawValue)")
        }
    }

    // MARK: - Initializer
    init(date: Date, type: ServiceType, amount: Double, dogOwner: DogOwner, notes: String? = nil, petBadges: [String] = []) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.amount = max(0, amount) // Ensure no negative amount
        self.dogOwner = dogOwner
        self.notes = notes
        self.petBadges = petBadges
    }

    // MARK: - Computed Properties

    /// Format the charge amount as currency with localization
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current  // Ensures currency format is localized
        return formatter.string(from: NSNumber(value: amount)) ?? "\(formatter.currencySymbol ?? "$")\(amount)"
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

    /// Add a badge to the charge for pet behavior tracking
    func addBadge(_ badge: String) {
        guard !petBadges.contains(badge) else { return }
        petBadges.append(badge)
    }

    /// Analyze pet behavior based on charge notes (placeholder logic)
    func analyzeBehavior() -> String {
        if let notes = notes, notes.lowercased().contains("anxious") {
            return NSLocalizedString("Behavioral analysis: Pet is anxious during appointments.", comment: "Behavioral analysis result")
        }
        return NSLocalizedString("Behavioral analysis: No significant behavioral notes.", comment: "Behavioral analysis result")
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
        let total = charges.filter { $0.isInMonth(month, year: year) }.reduce(0) { $0 + $1.amount }
        // Log or display this in a user-facing component
        print(NSLocalizedString("Total revenue for \(month)/\(year): \(total)", comment: "Total revenue log message"))
        return total
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

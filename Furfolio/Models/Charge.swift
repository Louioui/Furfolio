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
    var type: ServiceType
    var amount: Double
    @Relationship(deleteRule: .nullify) var dogOwner: DogOwner
    var notes: String?
    var petBadges: [String]

    // MARK: - Enum for Service Types
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
        self.amount = max(0, amount) // Prevent negative charges
        self.dogOwner = dogOwner
        self.notes = notes
        self.petBadges = petBadges
    }

    // MARK: - Computed Properties
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "\(formatter.currencySymbol ?? "$")\(amount)"
    }

    var formattedDate: String {
        date.formatted(.dateTime.month().day().year())
    }

    var isValid: Bool {
        amount > 0 && !type.rawValue.isEmpty
    }

    var isOverdue: Bool {
        date < Calendar.current.startOfDay(for: Date())
    }

    // MARK: - Methods
    func isInMonth(_ month: Int, year: Int) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: date) == month &&
               calendar.component(.year, from: date) == year
    }

    func applyDiscount(_ percentage: Double) {
        guard percentage > 0 && percentage <= 100 else { return }
        amount -= amount * (percentage / 100)
    }

    func addBadge(_ badge: String) {
        guard !petBadges.contains(badge) else { return }
        petBadges.append(badge)
    }

    func analyzeBehavior() -> String {
        guard let notes = notes?.lowercased() else { return NSLocalizedString("Behavioral analysis: No significant behavioral notes.", comment: "Behavioral analysis result") }

        if notes.contains("anxious") {
            return NSLocalizedString("Behavioral analysis: Pet is anxious during appointments.", comment: "Behavioral analysis result")
        } else if notes.contains("aggressive") {
            return NSLocalizedString("Behavioral analysis: Pet showed signs of aggression.", comment: "Behavioral analysis result")
        }
        return NSLocalizedString("Behavioral analysis: No significant behavioral notes.", comment: "Behavioral analysis result")
    }

    // MARK: - Static Methods
    static func totalByType(charges: [Charge]) -> [ServiceType: Double] {
        charges.reduce(into: [ServiceType: Double]()) { totals, charge in
            totals[charge.type, default: 0] += charge.amount
        }
    }

    static func totalRevenue(forMonth month: Int, year: Int, charges: [Charge]) -> Double {
        charges.filter { $0.isInMonth(month, year: year) }
               .reduce(0) { $0 + $1.amount }
    }

    static func chargesForOwner(_ owner: DogOwner, from charges: [Charge]) -> [Charge] {
        charges.filter { $0.dogOwner.id == owner.id }
    }

    static func overdueCharges(from charges: [Charge]) -> [Charge] {
        charges.filter { $0.isOverdue }
    }

    static func categorizeByType(_ charges: [Charge]) -> [ServiceType: [Charge]] {
        charges.reduce(into: [ServiceType: [Charge]]()) { categorized, charge in
            categorized[charge.type, default: []].append(charge)
        }
    }

    static func chargesInDateRange(_ range: ClosedRange<Date>, from charges: [Charge]) -> [Charge] {
        charges.filter { range.contains($0.date) }
    }

    static func totalRevenue(for range: ClosedRange<Date>, from charges: [Charge]) -> Double {
        chargesInDateRange(range, from: charges)
            .reduce(0) { $0 + $1.amount }
    }

    static func averageCharge(for type: ServiceType, from charges: [Charge]) -> Double {
        let chargesOfType = charges.filter { $0.type == type }
        guard !chargesOfType.isEmpty else { return 0 }
        let totalAmount = chargesOfType.reduce(0) { $0 + $1.amount }
        return totalAmount / Double(chargesOfType.count)
    }

    // MARK: - New Methods
    static func chargesForOwnerGroupedByMonth(_ owner: DogOwner, from charges: [Charge]) -> [Int: [Charge]] {
        chargesForOwner(owner, from: charges).reduce(into: [Int: [Charge]]()) { grouped, charge in
            let month = Calendar.current.component(.month, from: charge.date)
            grouped[month, default: []].append(charge)
        }
    }

    static func totalRevenueGroupedByMonth(for owner: DogOwner, from charges: [Charge]) -> [Int: Double] {
        chargesForOwnerGroupedByMonth(owner, from: charges).reduce(into: [Int: Double]()) { totals, chargeGroup in
            let month = chargeGroup.key
            let totalAmount = chargeGroup.value.reduce(0) { $0 + $1.amount }
            totals[month] = totalAmount
        }
    }
}

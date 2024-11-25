//
//  DailyRevenue.swift
//  Furfolio
//
//  Created by mac on 11/23/24.
//

import Foundation
import SwiftData

@Model
final class DailyRevenue: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var date: Date
    var totalAmount: Double

    init(date: Date, totalAmount: Double = 0.0) {
        self.id = UUID()
        self.date = date
        self.totalAmount = max(0, totalAmount) // Ensure no negative revenue
    }

    // MARK: - Computed Properties

    /// Format the total revenue as currency
    var formattedTotal: String {
        NumberFormatter.localizedString(from: NSNumber(value: totalAmount), number: .currency)
    }

    /// Format the revenue date for display
    var formattedDate: String {
        date.formatted(.dateTime.month().day().year())
    }

    /// Revenue for the current week
    var weeklyRevenue: Double {
        // Assume weekly revenue calculation
        totalAmount * 7
    }

    /// Revenue for the current month
    var monthlyRevenue: Double {
        // Assume 30-day calculation for simplicity
        totalAmount * 30
    }

    /// Determines if the record is for today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Determines if the record is for the current month
    var isCurrentMonth: Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: date) == calendar.component(.month, from: Date()) &&
               calendar.component(.year, from: date) == calendar.component(.year, from: Date())
    }

    // MARK: - Methods

    /// Add revenue to the total amount
    func addRevenue(amount: Double) {
        totalAmount += max(0, amount)
    }

    /// Reset the revenue total
    func resetRevenue() {
        totalAmount = 0.0
    }

    // MARK: - Static Methods

    /// Calculate total revenue for a date range
    static func totalRevenue(for range: ClosedRange<Date>, revenues: [DailyRevenue]) -> Double {
        revenues.filter { range.contains($0.date) }.reduce(0) { $0 + $1.totalAmount }
    }

    /// Calculate average daily revenue for a date range
    static func averageDailyRevenue(for range: ClosedRange<Date>, revenues: [DailyRevenue]) -> Double {
        let filteredRevenues = revenues.filter { range.contains($0.date) }
        let totalDays = Double(Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day ?? 0) + 1
        let totalRevenue = filteredRevenues.reduce(0) { $0 + $1.totalAmount }
        return totalDays > 0 ? totalRevenue / totalDays : 0
    }

    /// Get the revenue record for today
    static func revenueForToday(from revenues: [DailyRevenue]) -> DailyRevenue? {
        revenues.first { Calendar.current.isDateInToday($0.date) }
    }
}



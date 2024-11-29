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

    // MARK: - Initializer
    init(date: Date, totalAmount: Double = 0.0) {
        self.id = UUID()
        self.date = date
        self.totalAmount = max(0, totalAmount) // Ensure no negative revenue
    }

    // MARK: - Computed Properties

    /// Format the total revenue as currency
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter.string(from: NSNumber(value: totalAmount)) ?? "$\(totalAmount)"
    }

    /// Format the revenue date for display
    var formattedDate: String {
        date.formatted(.dateTime.month().day().year())
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

    /// Calculate weekly revenue (last 7 days from the current date)
    func calculateWeeklyRevenue(from revenues: [DailyRevenue]) -> Double {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -6, to: date) ?? date
        let range = startDate...date
        return DailyRevenue.totalRevenue(for: range, revenues: revenues)
    }

    /// Calculate monthly revenue (all days in the current month)
    func calculateMonthlyRevenue(from revenues: [DailyRevenue]) -> Double {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return totalAmount
        }
        let range = startOfMonth...endOfMonth
        return DailyRevenue.totalRevenue(for: range, revenues: revenues)
    }

    /// Calculate revenue for a specific date
    func calculateRevenue(for specificDate: Date, from revenues: [DailyRevenue]) -> Double {
        let calendar = Calendar.current
        return revenues.filter { calendar.isDate($0.date, inSameDayAs: specificDate) }
            .reduce(0) { $0 + $1.totalAmount }
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

    /// Get total revenue grouped by week
    static func weeklyRevenueSummary(from revenues: [DailyRevenue]) -> [(week: String, total: Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: revenues) { revenue in
            calendar.component(.weekOfYear, from: revenue.date)
        }

        return grouped.map { (week, revenues) in
            let total = revenues.reduce(0) { $0 + $1.totalAmount }
            return (week: NSLocalizedString("Week \(week)", comment: "Weekly revenue summary"), total: total)
        }
        .sorted { $0.week < $1.week }
    }
}

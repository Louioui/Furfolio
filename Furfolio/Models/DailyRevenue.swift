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
    init(date: Date, totalAmount: Double = 0.0) throws {
        guard totalAmount >= 0 else {
            throw RevenueError.negativeAmount
        }
        guard date <= Date() else {
            throw RevenueError.futureDate
        }
        self.id = UUID()
        self.date = date
        self.totalAmount = totalAmount

        // Schedule the daily reset
        scheduleDailyReset()
    }

    // MARK: - Error Handling
    enum RevenueError: Error {
        case negativeAmount
        case futureDate

        var localizedDescription: String {
            switch self {
            case .negativeAmount:
                return NSLocalizedString("Total amount cannot be negative.", comment: "Revenue Error: Negative Amount")
            case .futureDate:
                return NSLocalizedString("Date cannot be in the future.", comment: "Revenue Error: Future Date")
            }
        }
    }

    // MARK: - Computed Properties

    /// Formats the total amount as a localized currency string.
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter.string(from: NSNumber(value: totalAmount)) ?? "$\(totalAmount)"
    }

    /// Formats the date as a localized string.
    var formattedDate: String {
        date.formatted(.dateTime.month().day().year())
    }

    /// Checks if the revenue is for today's date.
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Checks if the revenue is for the current month.
    var isCurrentMonth: Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: date) == calendar.component(.month, from: Date()) &&
               calendar.component(.year, from: date) == calendar.component(.year, from: Date())
    }

    // MARK: - Methods

    /// Adds revenue to the total amount, ensuring the amount is non-negative.
    func addRevenue(amount: Double) {
        totalAmount += max(0, amount)
    }

    /// Resets the total revenue to 0.0 at the end of the day.
    func resetRevenue() {
        totalAmount = 0.0
    }

    /// Schedules a reset at midnight for the next day.
    func scheduleDailyReset() {
        let calendar = Calendar.current
        let now = Date()
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!

        Timer.scheduledTimer(withTimeInterval: nextMidnight.timeIntervalSince(now), repeats: false) { _ in
            self.resetRevenueTask()
        }
    }

    /// Timer task to reset the revenue.
    private func resetRevenueTask() {
        resetRevenue()
    }

    /// Calculates the total revenue for the past 7 days, including today.
    func calculateWeeklyRevenue(from revenues: [DailyRevenue]) -> Double {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -6, to: date) ?? date
        let range = startDate...date
        return DailyRevenue.totalRevenue(for: range, revenues: revenues)
    }

    /// Calculates the total revenue for the current month.
    func calculateMonthlyRevenue(from revenues: [DailyRevenue]) -> Double {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return totalAmount
        }
        let range = startOfMonth...endOfMonth
        return DailyRevenue.totalRevenue(for: range, revenues: revenues)
    }

    /// Calculates the revenue for a specific date.
    func calculateRevenue(for specificDate: Date, from revenues: [DailyRevenue]) -> Double {
        let calendar = Calendar.current
        return revenues.filter { calendar.isDate($0.date, inSameDayAs: specificDate) }
            .reduce(0) { $0 + $1.totalAmount }
    }

    // MARK: - Static Methods

    /// Calculates the total revenue for a specific date range.
    static func totalRevenue(for range: ClosedRange<Date>, revenues: [DailyRevenue]) -> Double {
        revenues.filter { range.contains($0.date) }.reduce(0) { $0 + $1.totalAmount }
    }

    /// Calculates the average daily revenue for a specific date range.
    static func averageDailyRevenue(for range: ClosedRange<Date>, revenues: [DailyRevenue]) -> Double {
        let filteredRevenues = revenues.filter { range.contains($0.date) }
        let totalDays = Double(Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day ?? 0) + 1
        let totalRevenue = filteredRevenues.reduce(0) { $0 + $1.totalAmount }
        return totalDays > 0 ? totalRevenue / totalDays : 0
    }

    /// Returns the revenue for today's date, if available.
    static func revenueForToday(from revenues: [DailyRevenue]) -> DailyRevenue? {
        revenues.first { Calendar.current.isDateInToday($0.date) }
    }

    /// Summarizes the total weekly revenue grouped by week.
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

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
    @Attribute var date: Date
    var totalAmount: Double
    @Relationship(deleteRule: .cascade) var dogOwner: DogOwner // Relationship to DogOwner

    // MARK: - Initializer
    init(date: Date, totalAmount: Double = 0.0, dogOwner: DogOwner) throws {
        guard totalAmount >= 0 else {
            throw RevenueError.negativeAmount
        }
        guard date <= Date() else {
            throw RevenueError.futureDate
        }
        self.id = UUID()
        self.date = date
        self.totalAmount = totalAmount
        self.dogOwner = dogOwner
    }

    // MARK: - Error Handling
    enum RevenueError: Error, LocalizedError {
        case negativeAmount
        case futureDate

        var errorDescription: String? {
            switch self {
            case .negativeAmount:
                return NSLocalizedString("Total amount cannot be negative.", comment: "Revenue Error: Negative Amount")
            case .futureDate:
                return NSLocalizedString("Date cannot be in the future.", comment: "Revenue Error: Future Date")
            }
        }
    }

    // MARK: - Computed Properties

    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter.string(from: NSNumber(value: totalAmount)) ?? "$\(totalAmount)"
    }

    var formattedDate: String {
        date.formatted(.dateTime.month().day().year())
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var isCurrentMonth: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }

    // MARK: - Methods

    func addRevenue(amount: Double) {
        guard amount >= 0 else { return }
        totalAmount += amount
    }

    func resetIfNotToday() {
        if !isToday {
            totalAmount = 0.0
        }
    }

    func calculateWeeklyRevenue(from revenues: [DailyRevenue]) -> Double {
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date()
        return DailyRevenue.totalRevenue(for: startDate...Date(), revenues: revenues)
    }

    func calculateMonthlyRevenue(from revenues: [DailyRevenue]) -> Double {
        guard let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date)),
              let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)?.addingTimeInterval(-1) else {
            return totalAmount
        }
        return DailyRevenue.totalRevenue(for: startOfMonth...endOfMonth, revenues: revenues)
    }

    func calculateRevenue(for specificDate: Date, from revenues: [DailyRevenue]) -> Double {
        revenues.filter { Calendar.current.isDate($0.date, inSameDayAs: specificDate) }
            .reduce(0) { $0 + $1.totalAmount }
    }

    // MARK: - Static Methods

    static func totalRevenue(for range: ClosedRange<Date>, revenues: [DailyRevenue]) -> Double {
        revenues.filter { range.contains($0.date) }
            .reduce(0) { $0 + $1.totalAmount }
    }

    static func averageDailyRevenue(for range: ClosedRange<Date>, revenues: [DailyRevenue]) -> Double {
        let filteredRevenues = revenues.filter { range.contains($0.date) }
        let totalDays = Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day ?? 0
        guard totalDays > 0 else { return 0 }
        let totalRevenue = filteredRevenues.reduce(0) { $0 + $1.totalAmount }
        return totalRevenue / Double(totalDays + 1)
    }

    static func revenueForToday(from revenues: [DailyRevenue]) -> DailyRevenue? {
        revenues.first { $0.isToday }
    }

    static func weeklyRevenueSummary(from revenues: [DailyRevenue]) -> [(week: String, total: Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: revenues) { calendar.component(.weekOfYear, from: $0.date) }

        return grouped.map { (week, weeklyRevenues) in
            let total = weeklyRevenues.reduce(0) { $0 + $1.totalAmount }
            return (week: NSLocalizedString("Week \(week)", comment: "Weekly revenue summary"), total: total)
        }
        .sorted { $0.week < $1.week }
    }

    // MARK: - New Static Methods for Improved Revenue Calculations

    static func totalRevenueForOwner(owner: DogOwner, from revenues: [DailyRevenue]) -> Double {
        let ownerRevenues = revenues.filter { $0.dogOwner.id == owner.id }
        return ownerRevenues.reduce(0) { $0 + $1.totalAmount }
    }

    static func dailyRevenueSummary(for month: Int, year: Int, revenues: [DailyRevenue]) -> [(day: String, total: Double)] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!.addingTimeInterval(-1)
        
        let monthlyRevenues = revenues.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
        
        let groupedByDay = Dictionary(grouping: monthlyRevenues) {
            calendar.component(.day, from: $0.date)
        }
        
        return groupedByDay.map { (day, dayRevenues) in
            let total = dayRevenues.reduce(0) { $0 + $1.totalAmount }
            return (day: "\(day)", total: total)
        }
        .sorted { Int($0.day)! < Int($1.day)! }
    }

    static func weeklyRevenueSummary(for year: Int, revenues: [DailyRevenue]) -> [(week: String, total: Double)] {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: year))!
        let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!

        let filteredRevenues = revenues.filter { $0.date >= startOfYear && $0.date <= endOfYear }
        
        let groupedByWeek = Dictionary(grouping: filteredRevenues) {
            calendar.component(.weekOfYear, from: $0.date)
        }
        
        return groupedByWeek.map { (week, weekRevenues) in
            let total = weekRevenues.reduce(0) { $0 + $1.totalAmount }
            return (week: NSLocalizedString("Week \(week)", comment: "Weekly revenue summary"), total: total)
        }
        .sorted { $0.week < $1.week }
    }
}

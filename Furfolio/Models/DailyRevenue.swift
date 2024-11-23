//
//  DailyRevenue.swift
//  Furfolio
//
//  Created by mac on 11/21/24.
//


import Foundation
import SwiftData

@Model
final class DailyRevenue: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var amount: Double

    // Initialization
    init(date: Date, amount: Double) {
        self.id = UUID()
        self.date = date
        self.amount = amount
    }

    // Function to reset the daily revenue (useful for checking new day)
    func resetAmount() {
        self.amount = 0.0
    }

    // Helper method to check if the revenue is from the same day
    static func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    // Helper method to calculate total revenue for a given date range
    static func totalRevenue(for revenues: [DailyRevenue], from startDate: Date, to endDate: Date) -> Double {
        return revenues.filter { $0.date >= startDate && $0.date <= endDate }
                       .reduce(0) { $0 + $1.amount }
    }

    // Computed property to determine if the current entry is for today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self.date)
    }

    // Computed property to determine if the current entry is in the current month
    var isInCurrentMonth: Bool {
        let calendar = Calendar.current
        let now = Date()
        return calendar.isDate(self.date, equalTo: now, toGranularity: .month)
    }
}

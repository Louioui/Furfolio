//
//  DailyRevenue.swift
//  Furfolio
//
//  Created by mac on 11/21/24.
//

// DailyRevenue.swift
// DailyRevenue.swift
// Furfolio
//
// Created by mac on 11/21/24.
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
}

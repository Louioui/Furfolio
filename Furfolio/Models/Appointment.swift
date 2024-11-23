//
//  Appointment.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//
import Foundation
import SwiftData

@Model
final class Appointment: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var dogOwner: DogOwner
    var isCanceled: Bool = false  // Tracks cancellations

    init(date: Date, dogOwner: DogOwner, isCanceled: Bool = false) {
        self.id = UUID()
        self.date = date
        self.dogOwner = dogOwner
        self.isCanceled = isCanceled
    }

    // Computed property to check if the appointment is completed
    var isCompleted: Bool {
        return date < Date() && !isCanceled
    }

    // Computed property to check if the appointment is upcoming
    var isUpcoming: Bool {
        return date > Date() && !isCanceled
    }

    // Optional: Add a property for notifications or reminders
    var requiresReminder: Bool {
        return isUpcoming && Calendar.current.isDateInTomorrow(date)
    }
}

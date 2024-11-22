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
    var isCanceled: Bool = false  // Added to track cancellations

    init(date: Date, dogOwner: DogOwner, isCanceled: Bool = false) {
        self.id = UUID()
        self.date = date
        self.dogOwner = dogOwner
        self.isCanceled = isCanceled
    }

    // Computed property to check if appointment is completed (past date and not canceled)
    var isCompleted: Bool {
        return date < Date() && !isCanceled
    }

    // Computed property to check if appointment is upcoming
    var isUpcoming: Bool {
        return date > Date() && !isCanceled
    }
}

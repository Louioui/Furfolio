//
//  DogOwner.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

import SwiftData
import Foundation

@Model
final class DogOwner: Identifiable {
    @Attribute(.unique) var id: UUID
    var ownerName: String
    var dogName: String
    var breed: String
    var contactInfo: String
    var address: String
    var dogImage: Data?
    var notes: String
    var appointments: [Appointment] = []
    var charges: [Charge] = []

    init(ownerName: String, dogName: String, breed: String, contactInfo: String, address: String, dogImage: Data? = nil, notes: String = "") {
        self.id = UUID()
        self.ownerName = ownerName
        self.dogName = dogName
        self.breed = breed
        self.contactInfo = contactInfo
        self.address = address
        self.dogImage = dogImage
        self.notes = notes
    }

    // Computed property to get the next upcoming appointment
    var nextAppointment: Appointment? {
        return appointments
            .filter { $0.date > Date() && !$0.isCanceled }
            .sorted { $0.date < $1.date }
            .first
    }

    // Computed property to calculate the total charges for this owner
    var totalCharges: Double {
        return charges.reduce(0) { $0 + $1.amount }
    }

    // Computed property to get the most used service
    var mostUsedService: String? {
        let serviceCounts = charges.reduce(into: [String: Int]()) { counts, charge in
            counts[charge.type, default: 0] += 1
        }
        return serviceCounts.max(by: { $0.value < $1.value })?.key
    }
}


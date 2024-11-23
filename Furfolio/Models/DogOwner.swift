//
//  DogOwner.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//
// DogOwner.swift

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
    var dogImage: Data?  // Stores the profile image
    var notes: String
    var appointments: [Appointment] = []  // Relationship to appointments
    var charges: [Charge] = []  // Relationship to charges

    init(
        ownerName: String,
        dogName: String,
        breed: String,
        contactInfo: String,
        address: String,
        dogImage: Data? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.ownerName = ownerName
        self.dogName = dogName
        self.breed = breed
        self.contactInfo = contactInfo
        self.address = address
        self.dogImage = dogImage
        self.notes = notes
    }

    // Computed property to check for upcoming appointments
    var hasUpcomingAppointments: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return appointments.contains { $0.date > today }
    }

    // Next appointment (if available)
    var nextAppointment: Appointment? {
        return appointments.filter { $0.date > Date() }.sorted { $0.date < $1.date }.first
    }

    // Total charges for this owner
    var totalCharges: Double {
        return charges.reduce(0) { $0 + $1.amount }
    }

    // Popular services used by this owner
    var popularServices: [String: Int] {
        var serviceCounts: [String: Int] = [:]
        charges.forEach { charge in
            serviceCounts[charge.type, default: 0] += 1
        }
        return serviceCounts
    }
}


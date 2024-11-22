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
    var dogImage: Data? // Storing dog image
    var notes: String
    var appointments: [Appointment] = [] // Relationship to Appointment model
    var charges: [Charge] = [] // Relationship to Charge model

    init(
        ownerName: String,
        dogName: String,
        breed: String,
        contactInfo: String,
        address: String,
        dogImage: Data? = nil,
        notes: String = "",
        appointments: [Appointment] = [],
        charges: [Charge] = []
    ) {
        self.id = UUID()
        self.ownerName = ownerName
        self.dogName = dogName
        self.breed = breed
        self.contactInfo = contactInfo
        self.address = address
        self.dogImage = dogImage
        self.notes = notes
        self.appointments = appointments
        self.charges = charges
    }

    // Computed property to check if the owner has upcoming appointments
    var hasUpcomingAppointments: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return appointments.contains { $0.date > today }
    }

    // Computed property to get the next appointment
    var nextAppointment: Appointment? {
        return appointments.filter { $0.date > Date() }.sorted { $0.date < $1.date }.first
    }

    // Computed property to get the total charges for the owner
    var totalCharges: Double {
        return charges.reduce(0) { $0 + $1.amount }
    }

    // Computed property to count the number of charges (useful for frequent customers)
    var chargeCount: Int {
        return charges.count
    }

    // Helper method to get a list of services and their counts
    var popularServices: [String: Int] {
        var serviceCounts: [String: Int] = [:]
        charges.forEach { charge in
            serviceCounts[charge.type, default: 0] += 1
        }
        return serviceCounts
    }
}

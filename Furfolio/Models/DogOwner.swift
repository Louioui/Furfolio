//
//  DogOwner.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

import SwiftData
import Foundation
import UIKit

@Model
final class DogOwner: Identifiable {
    @Attribute(.unique) var id: UUID
    var ownerName: String
    var dogName: String
    var breed: String
    var contactInfo: String
    var address: String
    @Attribute(.externalStorage) var dogImage: Data? // Store large data externally
    var notes: String
    @Relationship(deleteRule: .cascade) var appointments: [Appointment] = []
    @Relationship(deleteRule: .cascade) var charges: [Charge] = []
    
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
    
    // MARK: - Computed Properties
    
    /// Check if the owner has upcoming appointments
    var hasUpcomingAppointments: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return appointments.contains { $0.date > today }
    }
    
    /// Get the owner's next appointment
    var nextAppointment: Appointment? {
        appointments
            .filter { $0.date > Date() }
            .sorted { $0.date < $1.date }
            .first
    }
    
    /// Calculate the total charges for the owner
    var totalCharges: Double {
        charges.reduce(0) { $0 + $1.amount }
    }
    
    /// Determine if the owner is active
    var isActive: Bool {
        hasUpcomingAppointments || recentActivity
    }

    /// Check if the owner has activity in the last 30 days
    private var recentActivity: Bool {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return charges.contains { $0.date >= thirtyDaysAgo } ||
               appointments.contains { $0.date >= thirtyDaysAgo }
    }
    
    /// Generate searchable text for the owner
    var searchableText: String {
        "\(ownerName) \(dogName) \(breed) \(contactInfo) \(address) \(notes)"
    }
    
    /// Convert the dog's image data to `UIImage`
    var dogUIImage: UIImage? {
        guard let data = dogImage else { return nil }
        return UIImage(data: data)
    }

    /// Count of all past appointments
    var pastAppointmentsCount: Int {
        appointments.filter { $0.date < Date() }.count
    }

    /// Count of all future appointments
    var upcomingAppointmentsCount: Int {
        appointments.filter { $0.date > Date() }.count
    }

    // MARK: - Methods
    
    /// Validate the dog's image for size and format
    func isValidImage() -> Bool {
        guard let data = dogImage, let image = UIImage(data: data) else { return false }
        let maxSizeMB = 5.0
        let dataSizeMB = Double(data.count) / (1024.0 * 1024.0)
        return dataSizeMB <= maxSizeMB && image.size.width > 100 && image.size.height > 100
    }

    /// Remove all past appointments
    func removePastAppointments() {
        appointments.removeAll { $0.date < Date() }
    }

    /// Get charges within a specific date range
    func chargesInDateRange(startDate: Date, endDate: Date) -> [Charge] {
        charges.filter { $0.date >= startDate && $0.date <= endDate }
    }

    /// Add a new charge
    func addCharge(date: Date, type: String, amount: Double, notes: String = "") {
        let newCharge = Charge(date: date, type: type, amount: amount, dogOwner: self, notes: notes)
        charges.append(newCharge)
    }
}



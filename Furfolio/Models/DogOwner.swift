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

    // MARK: - Initializer
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
        self.ownerName = NSLocalizedString(ownerName, comment: "Owner's name")
        self.dogName = NSLocalizedString(dogName, comment: "Dog's name")
        self.breed = NSLocalizedString(breed, comment: "Dog breed")
        self.contactInfo = NSLocalizedString(contactInfo, comment: "Contact information")
        self.address = NSLocalizedString(address, comment: "Owner's address")
        self.dogImage = dogImage
        self.notes = NSLocalizedString(notes, comment: "Additional notes")
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

    /// Resize the dog's image to a specific width while maintaining aspect ratio
    func resizeImage(targetWidth: CGFloat) -> Data? {
        guard let data = dogImage, let image = UIImage(data: data) else { return nil }
        let scale = targetWidth / image.size.width
        let targetHeight = image.size.height * scale
        let newSize = CGSize(width: targetWidth, height: targetHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage?.jpegData(compressionQuality: 0.8)
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
        let chargeType = Charge.ServiceType(rawValue: NSLocalizedString(type, comment: "Charge type")) ?? .custom
        let newCharge = Charge(date: date, type: chargeType, amount: amount, dogOwner: self, notes: NSLocalizedString(notes, comment: "Charge notes"))
        charges.append(newCharge)
    }

    /// Add a new appointment
    func addAppointment(date: Date, serviceType: String, notes: String = "") {
        let appointmentType = Appointment.ServiceType(rawValue: NSLocalizedString(serviceType, comment: "Service type")) ?? .custom
        let newAppointment = Appointment(date: date, dogOwner: self, serviceType: appointmentType, notes: NSLocalizedString(notes, comment: "Appointment notes"))
        appointments.append(newAppointment)
    }
}

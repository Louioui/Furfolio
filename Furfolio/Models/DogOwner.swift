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
    var birthdate: Date? // Optional birthdate for the dog
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
        notes: String = "",
        birthdate: Date? = nil
    ) {
        self.id = UUID()
        self.ownerName = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dogName = dogName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.breed = breed.trimmingCharacters(in: .whitespacesAndNewlines)
        self.contactInfo = contactInfo.trimmingCharacters(in: .whitespacesAndNewlines)
        self.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dogImage = dogImage
        self.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        self.birthdate = birthdate
    }

    // MARK: - Computed Properties

    var hasUpcomingAppointments: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return appointments.contains { $0.date > today }
    }

    var nextAppointment: Appointment? {
        appointments
            .filter { $0.date > Date() }
            .sorted { $0.date < $1.date }
            .first
    }

    var totalCharges: Double {
        charges.reduce(0) { $0 + $1.amount }
    }

    var isActive: Bool {
        hasUpcomingAppointments || recentActivity
    }

    private var recentActivity: Bool {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return charges.contains { $0.date >= thirtyDaysAgo } ||
               appointments.contains { $0.date >= thirtyDaysAgo }
    }

    var searchableText: String {
        "\(ownerName) \(dogName) \(breed) \(contactInfo) \(address) \(notes)"
    }

    var dogUIImage: UIImage? {
        guard let data = dogImage else { return nil }
        return UIImage(data: data)
    }

    var age: Int? {
        guard let birthdate = birthdate else { return nil }
        return calculateAge(from: birthdate)
    }

    var pastAppointmentsCount: Int {
        appointments.filter { $0.date < Date() }.count
    }

    var upcomingAppointmentsCount: Int {
        appointments.filter { $0.date > Date() }.count
    }

    // MARK: - Methods

    func isValidImage() -> Bool {
        guard let data = dogImage, let image = UIImage(data: data) else { return false }
        let maxSizeMB = 5.0
        let dataSizeMB = Double(data.count) / (1024.0 * 1024.0)
        let isValidSize = dataSizeMB <= maxSizeMB
        let isValidDimensions = image.size.width > 100 && image.size.height > 100
        let isValidFormat = (data.isJPEG || data.isPNG)
        return isValidSize && isValidDimensions && isValidFormat
    }

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

    func removePastAppointments() {
        appointments.removeAll { $0.date < Date() }
    }

    func chargesInDateRange(startDate: Date, endDate: Date) -> [Charge] {
        charges.filter { $0.date >= startDate && $0.date <= endDate }
    }

    func addCharge(date: Date, type: Charge.ServiceType, amount: Double, notes: String = "") {
        guard amount > 0 else { return }
        let newCharge = Charge(date: date, type: type, amount: amount, dogOwner: self, notes: notes)
        charges.append(newCharge)
    }

    func addAppointment(date: Date, serviceType: Appointment.ServiceType, notes: String = "") {
        guard date > Date() else { return }
        let newAppointment = Appointment(date: date, dogOwner: self, serviceType: serviceType, notes: notes)
        appointments.append(newAppointment)
    }

    func updateInfo(
        ownerName: String,
        dogName: String,
        breed: String,
        contactInfo: String,
        address: String,
        dogImage: Data?,
        notes: String
    ) {
        self.ownerName = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dogName = dogName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.breed = breed.trimmingCharacters(in: .whitespacesAndNewlines)
        self.contactInfo = contactInfo.trimmingCharacters(in: .whitespacesAndNewlines)
        self.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dogImage = dogImage
        self.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func analyzeBehavior() -> String {
        let lowercasedNotes = notes.lowercased()

        if lowercasedNotes.contains("anxious") {
            return NSLocalizedString("Pet appears anxious and may need additional care.", comment: "Behavioral analysis: Anxious pet")
        } else if lowercasedNotes.contains("aggressive") {
            return NSLocalizedString("Pet has shown signs of aggression. Handle with caution.", comment: "Behavioral analysis: Aggressive pet")
        } else if lowercasedNotes.contains("shy") {
            return NSLocalizedString("Pet appears shy and may need gentle handling.", comment: "Behavioral analysis: Shy pet")
        } else if lowercasedNotes.contains("playful") {
            return NSLocalizedString("Pet is playful and enjoys interactive playtime.", comment: "Behavioral analysis: Playful pet")
        } else if lowercasedNotes.contains("timid") {
            return NSLocalizedString("Pet is timid and may require extra patience.", comment: "Behavioral analysis: Timid pet")
        }

        return NSLocalizedString("No significant behavioral concerns noted.", comment: "Behavioral analysis: No issues")
    }

    func summarizeActivity() -> String {
        let summary = """
        Name: \(ownerName)
        Dog: \(dogName) (\(breed))
        Total Charges: \(totalCharges.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
        Upcoming Appointments: \(upcomingAppointmentsCount)
        Recent Activity: \(isActive ? "Active" : "Inactive")
        """
        return summary
    }

    // MARK: - Tagging (New Feature)
    var tags: [String] {
        var tagList = [String]()
        if breed.lowercased() == "bulldog" {
            tagList.append("Stubborn")
        }
        if notes.lowercased().contains("timid") {
            tagList.append("Timid")
        }
        return tagList
    }

    // MARK: - Helper Methods

    private func calculateAge(from birthdate: Date) -> Int? {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: Date())
        return ageComponents.year
    }
}

extension Data {
    var isJPEG: Bool {
        // JPEG images start with bytes: 0xFF 0xD8 and end with 0xFF 0xD9
        return self.starts(with: [0xFF, 0xD8]) && self.suffix(2) == [0xFF, 0xD9]
    }
    
    var isPNG: Bool {
        // PNG images start with: 0x89 0x50 0x4E 0x47
        return self.starts(with: [0x89, 0x50, 0x4E, 0x47])
    }
}

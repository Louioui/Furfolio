import SwiftData
import Foundation
import UIKit

@Model
final class DogOwner: Identifiable, ObservableObject {
    // Stored properties with proper property wrappers
    @Attribute(.unique) var id: UUID
    @Attribute var ownerName: String
    @Attribute var dogName: String
    @Attribute var breed: String
    @Attribute var contactInfo: String
    @Attribute var address: String
    @Attribute(.externalStorage) var dogImage: Data? // Store large data externally
    @Attribute var notes: String
    @Attribute var birthdate: Date? // Optional birthdate for the dog
    
    // Use @Relationship for relationships, not @Attribute
    @Relationship(deleteRule: .cascade) var appointments: [Appointment] = []
    @Relationship(deleteRule: .cascade) var charges: [Charge] = []
    @Relationship(deleteRule: .cascade) var healthRecords: [HealthRecord] = [] // Add relationship to HealthRecord
    
    // Non-relationship properties can still use @Attribute
    @Attribute var badges: [String] = [] // Added badges array
    @Attribute var behaviorTags: [String] = [] // Added behavioral tags array

    // MARK: - Initializer
    init(
        ownerName: String,
        dogName: String,
        breed: String,
        contactInfo: String,
        address: String,
        dogImage: Data? = nil,
        notes: String = "",
        birthdate: Date? = nil,
        healthRecords: [HealthRecord] = [], // Add healthRecords parameter to initializer
        behaviorTags: [String] = [] // Added behavioral tags to initializer
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
        self.healthRecords = healthRecords // Initialize healthRecords
        self.behaviorTags = behaviorTags // Initialize behavioral tags
    }

    // MARK: - Badge Management (New Feature)
    func addBadge(_ badge: String) {
        if !badges.contains(badge) {
            badges.append(badge)
        }
    }

    // MARK: - Behavioral Tags Management
    func addBehavioralTag(_ tag: String) {
        if !behaviorTags.contains(tag) {
            behaviorTags.append(tag)
        }
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

    func addHealthRecord(date: Date, healthCondition: String, treatment: String, notes: String = "") {
        let newHealthRecord = HealthRecord(dogOwner: self, date: date, healthCondition: healthCondition, treatment: treatment, notes: notes)
        healthRecords.append(newHealthRecord)
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

    // MARK: - Dog Computed Property
    var dog: Dog {
        return Dog(name: dogName, breed: breed, badges: badges, behaviorTags: behaviorTags)
    }
}

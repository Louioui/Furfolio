//
//  Appointment.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

import Foundation
import SwiftData
import UserNotifications

@Model
final class Appointment: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    @Relationship(deleteRule: .nullify) var dogOwner: DogOwner
    var petBirthdays: [Date] // Track pet birthdays for reminders

    enum ServiceType: String, Codable, CaseIterable {
        case basic = "Basic Package"
        case full = "Full Package"
        case custom = "Custom Package"

        var localized: String {
            NSLocalizedString(self.rawValue, comment: "Localized description of \(self.rawValue)")
        }
    }

    var serviceType: ServiceType
    var notes: String?
    var isRecurring: Bool
    var recurrenceFrequency: RecurrenceFrequency?
    var isNotified: Bool = false
    var profileBadges: [String] // Profile badges for pets

    enum RecurrenceFrequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"

        var localized: String {
            NSLocalizedString(self.rawValue, comment: "Localized description of \(self.rawValue)")
        }
    }

    // MARK: - Initializer
    init(
        date: Date,
        dogOwner: DogOwner,
        serviceType: ServiceType,
        notes: String? = nil,
        isRecurring: Bool = false,
        recurrenceFrequency: RecurrenceFrequency? = nil,
        petBirthdays: [Date] = [],
        profileBadges: [String] = []
    ) {
        self.id = UUID()
        self.date = date
        self.dogOwner = dogOwner
        self.serviceType = serviceType
        self.notes = notes
        self.isRecurring = isRecurring
        self.recurrenceFrequency = recurrenceFrequency
        self.petBirthdays = petBirthdays
        self.profileBadges = profileBadges
    }

    // MARK: - Computed Properties

    /// Check if the appointment is valid (future date)
    var isValid: Bool {
        date > Date()
    }

    /// Check if the appointment is a past event
    var isPast: Bool {
        date <= Date()
    }

    /// Time until the appointment in minutes
    var timeUntil: Int? {
        guard isValid else { return nil }
        return Calendar.current.dateComponents([.minute], from: Date(), to: date).minute
    }

    /// Format the appointment date for display
    var formattedDate: String {
        date.formatted(.dateTime.month().day().hour().minute())
    }

    /// Check for upcoming pet birthdays
    var upcomingBirthdays: [Date] {
        petBirthdays.filter { Calendar.current.isDateInToday($0) }
    }

    // MARK: - Methods

    /// Check for conflicts with another appointment
    func conflictsWith(other: Appointment, bufferMinutes: Int = 60) -> Bool {
        abs(self.date.timeIntervalSince(other.date)) < TimeInterval(bufferMinutes * 60)
    }

    /// Generate a series of recurring appointments based on the specified frequency
    func generateRecurrences(until endDate: Date) -> [Appointment] {
        guard isRecurring, let recurrenceFrequency = recurrenceFrequency else { return [] }
        
        var appointments: [Appointment] = []
        var nextDate = date
        
        while nextDate <= endDate {
            let newAppointment = Appointment(
                date: nextDate,
                dogOwner: dogOwner,
                serviceType: serviceType,
                notes: notes,
                isRecurring: true,
                recurrenceFrequency: recurrenceFrequency
            )
            appointments.append(newAppointment)
            
            switch recurrenceFrequency {
            case .daily:
                nextDate = Calendar.current.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
            case .weekly:
                nextDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: nextDate) ?? nextDate
            case .monthly:
                nextDate = Calendar.current.date(byAdding: .month, value: 1, to: nextDate) ?? nextDate
            }
        }
        
        return appointments
    }

    /// Schedule a notification for the appointment
    func scheduleNotification() {
        guard !isNotified, isValid else { return }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Upcoming Appointment", comment: "Notification title")
        content.body = String(format: NSLocalizedString("You have a %@ appointment for %@ at %@.", comment: "Notification body"), serviceType.localized, dogOwner.ownerName, formattedDate)
        content.sound = .default

        // Schedule notification 30 minutes before the appointment time
        guard let triggerDate = Calendar.current.date(byAdding: .minute, value: -30, to: date) else { return }
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)

        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }

        isNotified = true
    }

    /// Cancel a scheduled notification
    func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        isNotified = false
    }

    /// Add a badge to a pet profile
    func addBadge(_ badge: String) {
        guard !profileBadges.contains(badge) else { return }
        profileBadges.append(badge)
    }

    /// Analyze pet behavior based on profile notes
    func analyzeBehavior() -> String {
        if let notes = notes?.lowercased() {
            if notes.contains("anxious") {
                return NSLocalizedString("The pet is anxious and may need extra care during appointments.", comment: "Behavior analysis: Anxious")
            } else if notes.contains("aggressive") {
                return NSLocalizedString("The pet has shown signs of aggression. Please handle with caution.", comment: "Behavior analysis: Aggressive")
            }
        }
        return NSLocalizedString("No significant behavioral issues noted.", comment: "Behavior analysis: Neutral")
    }
}

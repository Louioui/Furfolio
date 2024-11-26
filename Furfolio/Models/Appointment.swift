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

    enum ServiceType: String, Codable, CaseIterable {
        case basic = "Basic Package"
        case full = "Full Package"
        case custom = "Custom Package"
    }
    var serviceType: ServiceType
    var notes: String?
    var isRecurring: Bool
    var recurrenceFrequency: RecurrenceFrequency?
    var isNotified: Bool = false

    enum RecurrenceFrequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
    }

    // MARK: - Initializer
    init(date: Date, dogOwner: DogOwner, serviceType: ServiceType, notes: String? = nil, isRecurring: Bool = false, recurrenceFrequency: RecurrenceFrequency? = nil) {
        self.id = UUID()
        self.date = date
        self.dogOwner = dogOwner
        self.serviceType = serviceType
        self.notes = notes
        self.isRecurring = isRecurring
        self.recurrenceFrequency = recurrenceFrequency
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

    // MARK: - Methods

    /// Check for conflicts with another appointment
    func conflictsWith(other: Appointment, bufferMinutes: Int = 60) -> Bool {
        abs(self.date.timeIntervalSince(other.date)) < TimeInterval(bufferMinutes * 60)
    }

    /// Generate a series of recurring appointments based on the specified frequency
    func generateRecurrences(until endDate: Date) -> [Appointment] {
        guard isRecurring, let recurrenceFrequency else { return [] }
        
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
        content.title = "Upcoming Appointment"
        content.body = "You have a \(serviceType.rawValue) appointment for \(dogOwner.ownerName) at \(formattedDate)."
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

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
}


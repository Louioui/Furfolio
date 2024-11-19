//
//  Appointment.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//
import Foundation
import SwiftData

@Model
final class Appointment {
    let date: Date
    let serviceType: String
    let status: AppointmentStatus
    let notes: String? // Optional notes field
    var reminderDate: Date? // Field for reminder scheduling

    init(date: Date, serviceType: String, status: AppointmentStatus = .scheduled, notes: String? = nil, reminderDate: Date? = nil) {
        self.date = date
        self.serviceType = serviceType
        self.status = status
        self.notes = notes
        self.reminderDate = reminderDate // Initialize reminderDate
    }

    enum AppointmentStatus: String, Codable {
        case scheduled
        case completed
        case canceled
        case overdue
    }
}


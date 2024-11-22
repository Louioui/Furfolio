//
//  Appointment.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//
import Foundation
import SwiftData

@Model
final class Appointment: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var dogOwner: DogOwner

    init(date: Date, dogOwner: DogOwner) {
        self.id = UUID()
        self.date = date
        self.dogOwner = dogOwner
    }
}

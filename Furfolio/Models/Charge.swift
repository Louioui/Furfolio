//
//  Charge.swift
//  Furfolio
//
//  Created by mac on 11/18/24.

import Foundation
import SwiftData

@Model
final class Charge: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var type: String
    var amount: Double
    var dogOwner: DogOwner
    var notes: String

    init(date: Date, type: String, amount: Double, dogOwner: DogOwner, notes: String = "") {
        self.id = UUID()
        self.date = date
        self.type = type
        self.amount = amount
        self.dogOwner = dogOwner
        self.notes = notes
    }
}

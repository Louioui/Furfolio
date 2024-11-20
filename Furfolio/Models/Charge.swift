//
//  Charge.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//

import Foundation
import SwiftData

@Model
final class Charge: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date
    var type: String // "Basic Package" or "Full Package"
    var amount: Double
    var dogOwner: DogOwner

    init(date: Date, type: String, amount: Double, dogOwner: DogOwner) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.amount = amount
        self.dogOwner = dogOwner
    }
}

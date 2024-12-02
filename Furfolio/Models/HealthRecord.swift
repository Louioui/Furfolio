//
//  HealthRecord.swift
//  Furfolio
//
//  Created by mac on 12/1/24.
//

import SwiftData
import Foundation

@Model
final class HealthRecord: Identifiable {
    @Attribute var id: UUID
    var date: Date
    var healthCondition: String
    var treatment: String
    var notes: String?

    @Relationship(deleteRule: .cascade) var dogOwner: DogOwner

    // Initializer
    init(dogOwner: DogOwner, date: Date, healthCondition: String, treatment: String, notes: String? = nil) {
        self.id = UUID()
        self.dogOwner = dogOwner
        self.date = date
        self.healthCondition = healthCondition
        self.treatment = treatment
        self.notes = notes
    }
}

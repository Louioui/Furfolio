//
//  GroomingSession.swift
//  Furfolio
//
//  Created by mac on 11/19/24.
//

import SwiftData
import Foundation

@Model
class GroomingSession {
    @Attribute(.unique) var id: UUID
    var date: Date
    var servicesPerformed: String
    var groomerName: String
    var notes: String
    @Relationship var dogOwner: DogOwner

    init(date: Date, servicesPerformed: String, groomerName: String, notes: String, dogOwner: DogOwner) {
        self.id = UUID()
        self.date = date
        self.servicesPerformed = servicesPerformed
        self.groomerName = groomerName
        self.notes = notes
        self.dogOwner = dogOwner
    }
}

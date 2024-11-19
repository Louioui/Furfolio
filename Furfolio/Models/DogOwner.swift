//
//  DogOwner.swift
//  Furfolio
//
//  Created by mac on 11/18/24.
//


import Foundation
import SwiftData

@Model
final class DogOwner {
    let ownerName: String
    let dogName: String
    let breed: String
    let contactInfo: String
    let address: String
    var appointments: [Appointment] = []
    var chargeHistory: [Charge] = []
    var tags: String
    var notes: String // New field for notes

    init(ownerName: String, dogName: String, breed: String, contactInfo: String, address: String, tags: String = "", notes: String = "") {
        self.ownerName = ownerName
        self.dogName = dogName
        self.breed = breed
        self.contactInfo = contactInfo
        self.address = address
        self.tags = tags
        self.notes = notes
    }
}

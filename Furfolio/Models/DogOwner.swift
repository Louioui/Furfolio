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
    var chargeHistory: [Charge] = []
    var appointments: [Appointment] = []
    @Relationship var groomingSessions: [GroomingSession] = []

    // Image stored as Data (binary format)
    var dogImage: Data? // This stores the image in binary format
    
    // Notes for the dog owner (optional)
    var notes: String? // New property to store notes

    init(ownerName: String, dogName: String, breed: String, contactInfo: String, address: String, dogImage: Data? = nil, notes: String? = nil) {
        self.ownerName = ownerName
        self.dogName = dogName
        self.breed = breed
        self.contactInfo = contactInfo
        self.address = address
        self.dogImage = dogImage
        self.notes = notes // Initialize the notes
    }
}

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

    // New properties for behavior tracking and reminders (if applicable)
    var behaviorTags: [String] // For tracking behavior-related health issues
    var followUpRequired: Bool // Flag for follow-up reminders

    // Initializer
    init(
        dogOwner: DogOwner,
        date: Date,
        healthCondition: String,
        treatment: String,
        notes: String? = nil,
        behaviorTags: [String] = [],
        followUpRequired: Bool = false
    ) {
        self.id = UUID()
        self.dogOwner = dogOwner
        self.date = date
        self.healthCondition = healthCondition
        self.treatment = treatment
        self.notes = notes
        self.behaviorTags = behaviorTags
        self.followUpRequired = followUpRequired
    }

    // MARK: - Computed Properties
    var formattedDate: String {
        date.formatted(.dateTime.month().day().year())
    }

    var formattedHealthCondition: String {
        return NSLocalizedString("Condition: \(healthCondition)", comment: "Health Condition")
    }

    var formattedTreatment: String {
        return NSLocalizedString("Treatment: \(treatment)", comment: "Treatment")
    }

    // MARK: - Methods
    func addBehaviorTag(_ tag: String) {
        if !behaviorTags.contains(tag) {
            behaviorTags.append(tag)
        }
    }

    func setFollowUpReminder(_ required: Bool) {
        followUpRequired = required
    }

    func summarize() -> String {
        return "\(formattedHealthCondition)\n\(formattedTreatment)\nNotes: \(notes ?? "No notes available.")"
    }
}

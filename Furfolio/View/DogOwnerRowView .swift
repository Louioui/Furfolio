//
//  DogOwnerRowView.swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//

import SwiftUI

struct DogOwnerRowView: View {
    let dogOwner: DogOwner

    var body: some View {
        HStack(spacing: 12) {
            dogImageSection()
            
            ownerDetailsSection()

            Spacer()

            upcomingAppointmentsTag()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Dog Image Section

    @ViewBuilder
    private func dogImageSection() -> some View {
        if let imageData = dogOwner.dogImage, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                .accessibilityLabel(String(format: NSLocalizedString("%@'s dog image", comment: "Accessibility label for dog image"), dogOwner.ownerName))
        } else {
            Circle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 50, height: 50)
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                .overlay(
                    Text(dogOwner.ownerName.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.white)
                )
                .accessibilityLabel(String(format: NSLocalizedString("%@'s initials", comment: "Accessibility label for initials"), dogOwner.ownerName))
        }
    }

    // MARK: - Owner Details Section

    @ViewBuilder
    private func ownerDetailsSection() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dogOwner.ownerName)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)

            Text(dogOwner.dogName)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)

            if !dogOwner.breed.isEmpty {
                Text(String(format: NSLocalizedString("Breed: %@", comment: "Label for dog breed"), dogOwner.breed))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            if !dogOwner.notes.isEmpty {
                Text(String(format: NSLocalizedString("Notes: %@", comment: "Label for notes"), dogOwner.notes))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
                    .lineLimit(2)
            }

            // Displaying behavioral tags if available
            if !dogOwner.behaviorTags.isEmpty {
                Text(String(format: NSLocalizedString("Behavior Tags: %@", comment: "Label for behavior tags"), dogOwner.behaviorTags.joined(separator: ", ")))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Upcoming Appointments Tag

    @ViewBuilder
    private func upcomingAppointmentsTag() -> some View {
        if dogOwner.hasUpcomingAppointments {
            Text(NSLocalizedString("Upcoming", comment: "Label for upcoming appointments"))
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.blue)
                .accessibilityLabel(NSLocalizedString("Upcoming appointments", comment: "Accessibility label for upcoming appointments tag"))
        }
    }
}

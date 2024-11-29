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
        HStack {
            // Dog Image or Placeholder
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

            // Owner and Dog Details
            VStack(alignment: .leading, spacing: 4) {
                Text(dogOwner.ownerName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(dogOwner.dogName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if !dogOwner.breed.isEmpty {
                    Text(String(format: NSLocalizedString("Breed: %@", comment: "Label for dog breed"), dogOwner.breed))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !dogOwner.notes.isEmpty {
                    Text(String(format: NSLocalizedString("Notes: %@", comment: "Label for notes"), dogOwner.notes))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            Spacer()

            // Upcoming Appointments Tag
            if dogOwner.hasUpcomingAppointments {
                Text(NSLocalizedString("Upcoming", comment: "Label for upcoming appointments"))
                    .font(.caption2)
                    .padding(6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.blue)
                    .accessibilityLabel(NSLocalizedString("Upcoming appointments", comment: "Accessibility label for upcoming appointments tag"))
            }

            // Total Charges
            if dogOwner.totalCharges > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(dogOwner.totalCharges.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                        .font(.caption)
                        .foregroundColor(.green)
                        .accessibilityLabel(String(format: NSLocalizedString("Total charges: %@", comment: "Accessibility label for total charges"), dogOwner.totalCharges.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))))
                }
                .padding(.leading, 8)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Ensure tap area includes entire row
        .accessibilityElement(children: .combine)
        .accessibilityHint(String(format: NSLocalizedString("Tap to view details about %@ and their dog.", comment: "Accessibility hint for dog owner row"), dogOwner.ownerName))
    }
}

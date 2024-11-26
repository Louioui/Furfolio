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
                    .accessibilityLabel("\(dogOwner.ownerName)'s dog image")
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
                    .accessibilityLabel("\(dogOwner.ownerName)'s initials")
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
                    Text("Breed: \(dogOwner.breed)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !dogOwner.notes.isEmpty {
                    Text("Notes: \(dogOwner.notes)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            Spacer()

            // Upcoming Appointments Tag
            if dogOwner.hasUpcomingAppointments {
                Text("Upcoming")
                    .font(.caption2)
                    .padding(6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.blue)
                    .accessibilityLabel("Upcoming appointments")
            }

            // Total Charges
            if dogOwner.totalCharges > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(dogOwner.totalCharges, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.green)
                        .accessibilityLabel("Total charges: \(dogOwner.totalCharges.formatted(.currency(code: "USD")))")
                }
                .padding(.leading, 8)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Ensure tap area includes entire row
        .accessibilityElement(children: .combine)
        .accessibilityHint("Tap to view details about \(dogOwner.ownerName) and their dog.")
    }
}


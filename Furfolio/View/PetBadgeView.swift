//
//  PetBadgeView.swift
//  Furfolio
//
//  Created by mac on 12/1/24.
//


import SwiftUI

struct PetBadgeView: View {
    var dog: Dog
    @State private var badges: [String] = []

    // Sample badges for demonstration; these would come from your data model
    let allBadges = [
        "Good Behavior",
        "Timid",
        "Aggressive",
        "Special Shampoo",
        "Birthday Special"
    ]
    
    var body: some View {
        VStack {
            Text("\(dog.name)'s Badges")
                .font(.title)
                .padding()

            if badges.isEmpty {
                Text("No badges assigned yet.")
                    .italic()
                    .foregroundColor(.gray)
            } else {
                ForEach(badges, id: \.self) { badge in
                    BadgeView(badgeName: badge)
                        .padding(5)
                }
            }
            
            Button(action: assignRandomBadge) {
                Text("Assign Random Badge")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            // Example logic to load badges from a data model
            loadBadges()
        }
    }
    
    // Example function to load badges
    private func loadBadges() {
        // This would typically fetch badges from the Dog model or database
        badges = dog.badges
    }
    
    private func assignRandomBadge() {
        // Randomly assign a badge for demonstration
        let randomBadge = allBadges.randomElement() ?? "Good Behavior"
        badges.append(randomBadge)
    }
}

struct BadgeView: View {
    var badgeName: String

    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text(badgeName)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 5)
    }
}

struct PetBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        PetBadgeView(dog: Dog(name: "Buddy", badges: ["Good Behavior", "Timid"]))
    }
}

struct Dog {
    var name: String
    var badges: [String]
}

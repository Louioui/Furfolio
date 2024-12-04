import SwiftUI

// Dog Model
struct Dog {
    var name: String
    var breed: String
    var badges: [String]
    var behaviorTags: [String]  // Added behaviorTags property
}

// BadgeView Model
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

// TagView for displaying behavior tags
struct TagView: View {
    var tagName: String

    var body: some View {
        Text(tagName)
            .font(.caption)
            .foregroundColor(.white)
            .padding(6)
            .background(Color.green)
            .cornerRadius(8)
    }
}

// PetBadgeView
struct PetBadgeView: View {
    @ObservedObject var dogOwner: DogOwner  // DogOwner model
    var dog: Dog // Now this is passed from DogOwner

    // Sample badges for demonstration; these would come from your data model
    let allBadges = [
        "Good Behavior",
        "Timid",
        "Aggressive",
        "Special Shampoo",
        "Birthday Special"
    ]

    // Sample behavior tags
    let allBehaviorTags = [
        "Calm",
        "Energetic",
        "Shy",
        "Playful",
        "Curious"
    ]

    var body: some View {
        VStack {
            Text("\(dog.name)'s Badges")
                .font(.title)
                .padding()

            // Display badges
            if dogOwner.badges.isEmpty {
                Text("No badges assigned yet.")
                    .italic()
                    .foregroundColor(.gray)
            } else {
                VStack {
                    ForEach(dogOwner.badges, id: \.self) { badge in
                        BadgeView(badgeName: badge)
                            .padding(5)
                    }
                }
            }
            
            // Display behavior tags
            if dogOwner.behaviorTags.isEmpty {
                Text("No behavior tags assigned yet.")
                    .italic()
                    .foregroundColor(.gray)
            } else {
                VStack {
                    ForEach(dogOwner.behaviorTags, id: \.self) { tag in
                        TagView(tagName: tag)
                            .padding(5)
                    }
                }
            }

            // Button to assign a random badge and behavior tag
            Button(action: assignRandomBadgeAndTag) {
                Text("Assign Random Badge & Tag")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            // Logic to load badges and behavior tags from the data model
            loadBadges()
            loadBehaviorTags()
        }
    }

    // Function to load badges
    private func loadBadges() {
        // Here we could load badges from a database or model if necessary.
        // For now, badges are fetched directly from the dogOwner's badges array.
    }

    // Function to load behavior tags
    private func loadBehaviorTags() {
        // Here we could load behavior tags from a database or model if necessary.
        // For now, behavior tags are fetched directly from the dogOwner's behaviorTags array.
    }

    // Function to assign a random badge and a random behavior tag
    private func assignRandomBadgeAndTag() {
        // Randomly assign a badge for demonstration
        let randomBadge = allBadges.randomElement() ?? "Good Behavior"
        
        // Randomly assign a behavior tag for demonstration
        let randomTag = allBehaviorTags.randomElement() ?? "Calm"

        // Append the badge and tag to the dog's list
        dogOwner.badges.append(randomBadge)
        dogOwner.behaviorTags.append(randomTag)
        
        // Save the badge and tag in the DogOwner model (using the dogOwner's reference directly)
        dogOwner.addBadge(randomBadge)
        dogOwner.addBehavioralTag(randomTag)
    }
}

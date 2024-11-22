//
//  DogOwnerRowView .swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//
import SwiftUI

struct DogOwnerRowView: View {
    let dogOwner: DogOwner

    // Image Cache key based on dog owner ID or name
    private var imageCacheKey: String {
        return dogOwner.id.uuidString // Assuming DogOwner has an id property
    }

    var body: some View {
        HStack {
            imageView
            VStack(alignment: .leading) {
                Text(dogOwner.ownerName)
                    .font(.headline)
                Text(dogOwner.dogName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    // Extracting image handling into a computed property with type erasure
    private var imageView: some View {
        Group {
            if let imageData = dogOwner.dogImage, let image = UIImage(data: imageData) {
                // Cache the image if not already cached
                if ImageCache.shared.getImage(forKey: imageCacheKey) == nil {
                    ImageCache.shared.saveImage(image, forKey: imageCacheKey)
                }

                return AnyView(
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                )
            } else if let cachedImage = ImageCache.shared.getImage(forKey: imageCacheKey) {
                // Use cached image if available
                return AnyView(
                    Image(uiImage: cachedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                )
            } else {
                // Default image if none found
                return AnyView(
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 50, height: 50)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .overlay(Text(dogOwner.ownerName.prefix(1)))
                )
            }
        }
    }
}

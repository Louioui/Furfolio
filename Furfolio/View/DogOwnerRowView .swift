//
//  DogOwnerRowView .swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//

import SwiftUI

struct DogOwnerRowView: View {
    let dogOwner: DogOwner

    private var imageCacheKey: String {
        return dogOwner.id.uuidString
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

    private var imageView: some View {
        if let imageData = dogOwner.dogImage, let image = UIImage(data: imageData) {
            // Cache the image for reuse
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
            return AnyView(
                Image(uiImage: cachedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            )
        } else {
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

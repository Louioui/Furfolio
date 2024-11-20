//
//  DogOwnerRowView .swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//

import SwiftUI

struct DogOwnerRowView: View {
    let dogOwner: DogOwner

    var body: some View {
        HStack {
            if let imageData = dogOwner.dogImage, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 50, height: 50)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .overlay(Text(dogOwner.ownerName.prefix(1)))
            }

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
}

//
//  ImageCache.swift
//  Furfolio
//
//  Created by mac on 11/21/24.
//
import UIKit

class ImageCache {
    private let cache = NSCache<NSString, UIImage>()

    // Singleton instance
    static let shared = ImageCache()

    private init() {}

    // Get image from cache
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    // Save image to cache
    func saveImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    // Clear cache (optional)
    func clearCache() {
        cache.removeAllObjects()
    }
}


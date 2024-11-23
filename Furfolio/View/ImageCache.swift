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

    private init() {
        // Observe memory warnings to clear the cache automatically
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Get image from cache
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    // Save image to cache
    func saveImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    // Clear cache (manual or automatic)
    @objc func clearCache() {
        cache.removeAllObjects()
    }

    // Preload images to cache
    func preloadImages(_ images: [String: UIImage]) {
        images.forEach { key, image in
            cache.setObject(image, forKey: key as NSString)
        }
    }
}

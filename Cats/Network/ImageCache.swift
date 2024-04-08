//
//  ImageCache.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import UIKit

protocol ImageCaching {
    func getImage(url: NSURL) -> UIImage?
    func saveImage(_ image: UIImage, url: NSURL)
}

class ImageCache: ImageCaching {
    static let shared = ImageCache()
    
    private let cachedImages = NSCache<NSURL, UIImage>()
    
    func getImage(url: NSURL) -> UIImage? {
        if let image = cachedImages.object(forKey: url) {
            return image
        } else if let image = loadImageFromDisk(url: url) {
            cachedImages.setObject(image, forKey: url)
            return image
        }
        return nil
    }
    
    func saveImage(_ image: UIImage, url: NSURL) {
        cachedImages.setObject(image, forKey: url)
        saveImageToDisk(image, url: url)
    }
}


extension ImageCache {
    
    private func fileURL(for url: NSURL) -> URL? {
        guard let fileName = url.absoluteString?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }
        
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return directory?.appendingPathComponent(fileName)
    }
    
    private func saveImageToDisk(_ image: UIImage, url: NSURL) {
        guard let fileURL = fileURL(for: url) else { return }
        
        if let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData() {
            try? data.write(to: fileURL)
        }
    }
    
    private func loadImageFromDisk(url: NSURL) -> UIImage? {
        guard let fileURL = fileURL(for: url),
              let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}



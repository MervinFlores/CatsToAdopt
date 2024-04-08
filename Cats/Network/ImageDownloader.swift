//
//  ImageDownloader.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import UIKit
import Combine

class ImageDownloader: NSObject {
    private var session: URLSession?
    
    override init() {
        super.init()
        configureSession()
    }
    
    func downloadThumbnailImageFromUrlString(_ urlString: String) -> AnyPublisher<UIImage, NetworkError> {
        guard let session = self.session,
              let url = URL(string: urlString),
              let imageUrlToSave = NSURL(string: urlString) else {
            return Fail(error: NetworkError.invalidUrl)
                .eraseToAnyPublisher()
        }
        
        return downloadImageFromUrl(url, imageUrlToSave: imageUrlToSave, session: session)
    }
    
    func downloadOriginalImageFromUrlString(_ urlString: String, imageCollectionUrl: String) -> AnyPublisher<UIImage, NetworkError> {
        guard let session = self.session,
              let url = URL(string: urlString),
              let imageUrlToSave = NSURL(string: imageCollectionUrl) else {
            return Fail(error: NetworkError.invalidUrl)
                .eraseToAnyPublisher()
        }
        
        return downloadImageFromUrl(url, imageUrlToSave: imageUrlToSave, session: session)
    }
    
    private func downloadImageFromUrl(_ url: URL, imageUrlToSave: NSURL, session: URLSession) -> AnyPublisher<UIImage, NetworkError> {
        return session
            .dataTaskPublisher(for: url)
            .mapError { NetworkError.mapError($0) }
            .tryMap { response -> Data in
                if let httpUrlResponse = response.response as? HTTPURLResponse,
                   httpUrlResponse.statusCode != 200 {
                    throw NetworkError.mapErrorByStatusCode(httpUrlResponse.statusCode)
                }
                return response.data
            }
            .tryMap { data in
                guard let image = UIImage(data: data) else {
                    throw NetworkError.invalidImage
                }
                ImageCache.shared.saveImage(image, url: imageUrlToSave)
                return image
            }
            .mapError {
                return NetworkError.mapError($0)
            }
            .eraseToAnyPublisher()
    }
    
    private func configureSession() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.allowsConstrainedNetworkAccess = false
        config.allowsExpensiveNetworkAccess = false
        
        session = URLSession(configuration: config)
    }

}



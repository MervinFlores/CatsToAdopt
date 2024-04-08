//
//  CatDetailViewModel.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import Foundation
import Combine

class CatDetailViewModel: NSObject {
    let networkManager = NetworkManager()
    let imageDownloader = ImageDownloader()
    
    private var cancellable: AnyCancellable?
    @Published private(set) var originalImageUrl: String? = nil
    
    func fetchOriginalImageUrl(imageCollectionUrl: String) {
        cancellable = networkManager.fetchData([String].self, urlString: imageCollectionUrl)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    let _ = NetworkError.getMessageForError(error)
                    
                    switch error {
                    case .invalidUrl:
                        Util.saveToUserDefault(imageCollectionUrl, value: 0)
                    default:
                        ()
                    }
                case .finished:
                    Util.log("Original image url received")
                }
            }, receiveValue: { [weak self] imageCollection in
                let filteredOriginalImage = imageCollection.filter { $0.contains("orig.") }
                if let originalImageUrl = filteredOriginalImage.first {
                    self?.originalImageUrl = originalImageUrl
                }
            })
    }
    
}


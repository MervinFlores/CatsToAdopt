//
//  CatListViewModel.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import Foundation
import Combine

class CatListViewModel: ObservableObject {
    let networkManager = NetworkManager()
    let imageDownloader = ImageDownloader()
    
    private var cancellable: AnyCancellable?
    @Published private(set) var _items: [CatItem] = []
    @Published private(set) var errorMessage: String? = nil
    
    var items = [CatItem]()
    
    func fetchItems(useLocalData: Bool = true) {
        let publisher: AnyPublisher<[CatItem], NetworkError> = useLocalData ?
            networkManager.fetchLocalData([CatItem].self, fileName: "LocalCats") :
            networkManager.fetchData([CatItem].self, urlString: cataasListUrl)
            
        cancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = NetworkError.getMessageForError(error)
                case .finished:
                    Util.log("Cat items received")
                }
            } receiveValue: { [weak self] catItem in
                self?._items = catItem
            }
    }
}


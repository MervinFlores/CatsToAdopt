//
//  CatsListController+TableView.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import UIKit

// MARK: - UITableViewDataSource

extension CatsListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatItemCell.identifier, for: indexPath) as? CatItemCell
        else { return UITableViewCell() }
        
        let item = viewModel.items[indexPath.row]
        let dataItem = viewModel.items[indexPath.row]
        cell.configure(dataItem)
        
        let imageThumbUrlString = item.getImageURLString()
        
        if let imageThumbUrl = NSURL(string: imageThumbUrlString),
           let image = ImageCache.shared.getImage(url: imageThumbUrl) {
            cell.imgCat.image = image
            cell.imgCat.contentMode = .scaleAspectFill
        } else {
            viewModel.imageDownloader.downloadThumbnailImageFromUrlString(imageThumbUrlString)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        let _ = NetworkError.getMessageForError(error)
                        cell.imgCat.image = UIImage(systemName: "exclamationmark.triangle")
                        cell.imgCat.contentMode = .center
                    case .finished:
                        Util.log("Thumbnail image downloaded")
                    }
                } receiveValue: { image in
                    if let visibleCell = tableView.cellForRow(at: indexPath) as? CatItemCell {
                        visibleCell.imgCat.image = image
                        visibleCell.imgCat.contentMode = .scaleAspectFill
                    }
                }.store(in: &cancellables)
    }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CatsListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = viewModel.items[indexPath.row]
        performSegue(withIdentifier: segueDetail, sender: item)
    }
}



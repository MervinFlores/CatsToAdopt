//
//  CatDetailController.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import UIKit
import Combine

class CatDetailController: UITableViewController {
    @IBOutlet weak var imgCat: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var txtVwDescription: UITextView!
    
    static let identifier = "CatDetailController"
    
    var item: CatItem?
    
    private var dataItem: CatItem?
    private let viewModel = CatDetailViewModel()
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        dataItem = item
        
        lblTitle.text = prepareTitleText(owner: dataItem?.owner)
        lblName.text = "\("since".localized): \(DateHelper.shared.formatToMediumDate(dataItem?.createdAt ?? Date()))"
        lblDate.text = prepareDateText(owner: dataItem?.owner, date: dataItem?.updatedAt ?? Date())
        txtVwDescription.attributedText = prepareDescriptionText(owner: dataItem?.owner)
        
        configureTableView()
        fetchImage()
    }
    
    internal func hasValidOwner(_ owner: String?) -> Bool {
        guard let owner = owner,
              owner.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != "null",
              !owner.isEmpty else {
            return false
        }
        return true
    }

    internal func prepareDescriptionText(owner: String?) -> NSAttributedString {
        let descriptionText: String
        if hasValidOwner(owner) {
            descriptionText = "cats.list.description.adoptedCat".localized
        } else {
            descriptionText = "cats.list.description.openToAdoptCat".localized
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.systemGray
        ]
        
        return NSAttributedString(string: descriptionText, attributes: attributes)
    }

    internal func prepareDateText(owner: String?, date: Date) -> String {
        let formattedDate = DateHelper.shared.formatToMediumDate(date)
        return hasValidOwner(owner) ? "\("adopted".localized): \(formattedDate)" : "\("lastUpdate".localized): \(formattedDate)"
    }

    internal func prepareTitleText(owner: String?) -> String {
        return hasValidOwner(owner) ? "\("newOwner".localized): \(owner!)" : "availableToAdopt".localized
    }
    
    private func configureTableView() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = tableView.frame.height
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func fetchImage() {
        if let imageCollectionUrl = item?.getImageURLString() {
            if let imageUrl = NSURL(string: imageCollectionUrl),
               let image = ImageCache.shared.getImage(url: imageUrl) {
                imgCat.image = image
            } else {
                if let _ = UserDefaults.standard.value(forKey: imageCollectionUrl) {
                    let _ = NetworkError.getMessageForError(.originalImageUrlNotFound)
                } else {
                    downloadImageFromImageCollectionUrl(imageCollectionUrl)
                }
            }
        }
    }
    
    private func downloadImageFromImageCollectionUrl(_ imageCollectionUrl: String) {
        viewModel.fetchOriginalImageUrl(imageCollectionUrl: imageCollectionUrl)
        viewModel.$originalImageUrl.sink { originalImageUrl in
            if let originalImageUrl = originalImageUrl {
                self.viewModel.imageDownloader
                    .downloadOriginalImageFromUrlString(originalImageUrl, imageCollectionUrl: imageCollectionUrl)
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            let _ = NetworkError.getMessageForError(error)
                            
                            switch error {
                            case .invalidImage:
                                Util.saveToUserDefault(imageCollectionUrl, value: 0)
                            default:
                                ()
                            }
                        case .finished:
                            Util.log("Original image downloaded")
                        }
                    } receiveValue: { [weak self] image in
                        self?.imgCat.image = image
                    }.store(in: &self.cancellables)
            }
        }.store(in: &cancellables)
    }

}


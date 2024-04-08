//
//  CatsListController.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import UIKit
import Combine

class CatsListController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    static let identifier = "CatsListController"
    let viewModel = CatListViewModel()
    let segueDetail = "SegueDetail"
    var cancellables: [AnyCancellable] = []
    
    private let spinner = UIActivityIndicatorView(style: .large)
    private var alertController: UIAlertController?
    
    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if viewModel.items.count == 0 {
            showSpinner()
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        viewModel.networkManager.delegate = self
        title = "cats.list.title".localized
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 112
        tableView.rowHeight = UITableView.automaticDimension
        
        let catItemCellNib = UINib(nibName: CatItemCell.identifier, bundle: nil)
        tableView.register(catItemCellNib, forCellReuseIdentifier: CatItemCell.identifier)
    }
    
    private func loadItems() {
        viewModel.fetchItems()
        viewModel.$errorMessage.sink { [weak self] message in
            if let errorMessage = message {
                self?.showAlertNetworkError(message: errorMessage)
            }
        }.store(in: &cancellables)
        
        viewModel.$_items.sink { [weak self] items in
            if items.count > 0 {
                self?.hideAlert()
                self?.viewModel.items = items
                self?.tableView.reloadData()
                self?.hideSpinner()
            }
        }.store(in: &cancellables)
    }
    
    // MARK: - Spinner
    
    private func showSpinner() {
        let tableViewFrame = tableView.bounds
        var spinnerFrame = spinner.bounds
        
        spinnerFrame.origin.x = tableViewFrame.size.width/2 - spinnerFrame.size.width/2
        spinnerFrame.origin.y = tableViewFrame.size.height/2 - spinnerFrame.size.width/2
        
        spinner.frame = spinnerFrame
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        tableView.addSubview(spinner)
    }
    
    private func hideSpinner() {
        DispatchQueue.main.async {
            if self.spinner.isAnimating {
                self.spinner.stopAnimating()
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueDetail,
           let catDetailController = segue.destination as? CatDetailController,
           let item = sender as? CatItem {
            catDetailController.item = item
        }
    }
    
    // MARK: - Alert
    
    fileprivate func showAlertNetworkError(message: String) {
        alertController = UIAlertController(title: "network.error.title".localized, message: message, preferredStyle: .alert)
        
        guard let alertController = self.alertController
        else { return }
        
        let retryAction = UIAlertAction(title: NSLocalizedString("network.error.retry", comment: ""), style: .default) { _ in
            self.alertController?.dismiss(animated: true, completion: nil)
            self.spinner.startAnimating()
            self.loadItems()
        }
        
        alertController.addAction(retryAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func hideAlert() {
        DispatchQueue.main.async {
            self.alertController?.dismiss(animated: true, completion: nil)
        }
    }

}

// MARK: - NetworkManagerDelegate

extension CatsListController: NetworkManagerDelegate {
    func taskIsWaitingForConnectivity() {
        hideAlert()
        hideSpinner()
        showAlertNetworkError(message: "network.error.message.no.connection".localized)
    }
}



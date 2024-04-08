//
//  CatItemCell.swift
//  Cats
//
//  Created by Mervin Flores on 3/8/24.
//

import UIKit

class CatItemCell: UITableViewCell {
    @IBOutlet weak var imgCat: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var cellContainer: UIView!
    
    static let identifier = "CatItemCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupCellViewsShape()
    }
    
    private func setupCellViewsShape() {
        cellContainer.applyBorderWithCornerRadius()
        imgCat.applyBorderWithCornerRadius(borderColor:.clear
        )
    }
    
    func configure(_ dataItem: CatItem) {
        imgCat.image = UIImage(systemName: "clock")
        imgCat.contentMode = .center
        lblTitle.text = determineAvailability(owner: dataItem.owner)
        let availabilityText = determineAvailability(owner: dataItem.owner)
            lblTitle.text = availabilityText
        if availabilityText == "Available to Adopt" {
                lblTitle.textColor = greenAvailable
            } else {
                lblTitle.textColor = redUnavailable
            }
        let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = backgroundView
        
    }
    
    private func determineAvailability(owner: String?) -> String {
        guard let owner = owner, owner.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != "null", !owner.isEmpty else {
            return "Available to Adopt"
        }
        return "Adopted"
    }
    
}


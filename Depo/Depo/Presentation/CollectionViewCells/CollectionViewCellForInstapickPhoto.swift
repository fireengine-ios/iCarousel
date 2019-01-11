//
//  CollectionViewCellForInstapickPhoto.swift
//  Depo
//
//  Created by Andrei Novikau on 1/10/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CollectionViewCellForInstapickPhoto: BaseCollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var rankView: UIView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.clear
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.height * 0.5
        imageView.layer.borderColor = UIColor.lrTealish.cgColor
        imageView.layer.borderWidth = 1
        imageView.alpha = 1
        
        rankView.clipsToBounds = true
        rankView.layer.cornerRadius = rankView.bounds.height * 0.5
        rankView.backgroundColor = UIColor.lrTealish
        
        rankLabel.textColor = .white
        rankLabel.font = UIFont.TurkcellSaturaBolFont(size: 12)
        
        countLabel.textColor = ColorConstants.lightText
        countLabel.font = UIFont.TurkcellSaturaDemFont(size: 14)
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        selectionImageView.isHidden = !isSelectionActive
        selectionImageView.image = UIImage(named: isSelected ? "selected" : "notSelected")
        imageView.alpha = isSelected && isSelectionActive ? 0.75 : 1
    }
    
    func setup(with item: Item) {
        
    }
}

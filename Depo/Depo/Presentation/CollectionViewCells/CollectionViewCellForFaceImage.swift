//
//  CollectionViewCellForFaceImage.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class CollectionViewCellForFaceImage: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var progress: UIActivityIndicatorView!
    @IBOutlet private weak var selectionView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    static let borderW: CGFloat = 3
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = ColorConstants.fileGreedCellColor
        
        selectionView.layer.borderColor = ColorConstants.darcBlueColor.cgColor
        selectionView.layer.borderWidth = PhotosOrderCollectionViewCell.borderW
        selectionView.alpha = 0
        
        nameLabel?.textAlignment = .center
        nameLabel?.backgroundColor = UIColor.clear
        nameLabel?.textColor = UIColor.white
        nameLabel?.font = UIFont.TurkcellSaturaMedFont(size: 12.0)
        nameLabel?.text = ""
        
    }
    
    func setName(name: String) {
        nameLabel.text = name
    }
    
    func configurateWith(image: UIImage?){
        progress.stopAnimating()
        imageView.image = image
    }
    
    func setSelection(selection: Bool){
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.selectionView.alpha = selection ? 1 : 0
        }
    }
    
}

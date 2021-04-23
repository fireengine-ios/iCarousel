//
//  PhotosOrderCollectionViewCell.swift
//  Depo
//
//  Created by Oleg on 03.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class PhotosOrderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
    
    static let borderW: CGFloat = 3

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = ColorConstants.fileGreedCellColor.color
        
        selectionView.layer.borderColor = ColorConstants.darkBlueColor.color.cgColor
        selectionView.layer.borderWidth = PhotosOrderCollectionViewCell.borderW
        selectionView.alpha = 0
        
        positionLabel.backgroundColor = ColorConstants.darkBlueColor.color
        positionLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        positionLabel.textColor = ColorConstants.whiteColor.color
        positionLabel.text = ""
        
    }

    func configurateWith(image: UIImage?) {
        progress.stopAnimating()
        imageView.image = image
    }
    
    func setPosition(position: Int) {
        positionLabel.text = String(format: "%d", position)
    }
    
    func setSelection(selection: Bool) {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.selectionView.alpha = selection ? 1 : 0
        }
    }
    
}

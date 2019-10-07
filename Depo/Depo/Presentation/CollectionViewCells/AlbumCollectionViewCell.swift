//
//  AlbumCollectionViewCell.swift
//  Depo
//
//  Created by Oleg on 23.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var listViewIcon: LoadingImageView!
    @IBOutlet weak var listViewTitle: UILabel!
    @IBOutlet weak var listSelectionIcon: UIImageView!
    @IBOutlet weak var listShadowView: ShadowView!
    
    @IBOutlet weak var greedView: UIView!
    @IBOutlet weak var greedViewIcon: LoadingImageView!
    @IBOutlet weak var greedViewTitle: UILabel!
    @IBOutlet weak var greedSelectionIcon: UIImageView!
    @IBOutlet weak var greedShadowView: ShadowView!
    
    private func isBigSize() -> Bool {
        return frame.size.height > NumericConstants.albumCellListHeight
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        listViewTitle.textColor = ColorConstants.textGrayColor
        listViewTitle.font = UIFont.TurkcellSaturaRegFont(size: 18)
        
        
        greedViewTitle.textColor = ColorConstants.textGrayColor
        greedViewTitle.font = UIFont.TurkcellSaturaRegFont(size: 12)
        
    }
    
    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        guard let album = wrappedObj as? AlbumItem else {
            return
        }
        
        listViewTitle.text = album.name
        listViewIcon.loadImageForItem(object: album.preview)
        
        greedViewTitle.text = album.name
        greedViewIcon.loadImageForItem(object: album.preview)
        
        listView.isHidden = isBigSize()
        greedView.isHidden = !isBigSize()
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitNone
        accessibilityLabel = album.name
        
        setNeedsLayout()
        layoutIfNeeded()
        
        greedShadowView.addShadowView()
        listShadowView.addShadowView()
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        listSelectionIcon.isHidden = !isSelectionActive
        listSelectionIcon.image = UIImage(named: isSelected ? "selected" : "notSelected")
        listViewIcon.setBorderVisibility(visibility: isSelected)
        
        
        greedSelectionIcon.isHidden = !isSelectionActive
        greedSelectionIcon.image = UIImage(named: isSelected ? "selected" : "notSelected")
        greedViewIcon.setBorderVisibility(visibility: isSelected)
    }

}

//
//  FolderSelectionCollectionViewCell.swift
//  Depo
//
//  Created by Oleg on 09.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class FolderSelectionCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var smallContentImageView: SelectionImageView!
    @IBOutlet weak var smallCellSelectionView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var rightIconImageView: UIImageView!

    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        
        guard let wrappered = wrappedObj as? WrapData,
            isAlreadyConfigured
            else { return }
        
        fileNameLabel.text = wrappedObj.name
        
        if isCellSelectionEnabled {
            smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForNotSelectedWrapperedObject(fileType: wrappered.fileType)
        } else {
            smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: wrappered.fileType)
        }
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        smallCellSelectionView.isHidden = true
        smallContentImageView.isHidden = false
        
        isCellSelected = isSelected
        isCellSelectionEnabled = isSelectionActive
        if isSelectionActive {
            if !smallContentImageView.configured {
                smallCellSelectionView.isHidden = !isSelected
                smallContentImageView.isHidden = isSelected
            }
            smallContentImageView.setSelection(selection: isSelected, showSelectonBorder: isSelectionActive)
        } else {
            smallContentImageView.setSelection(selection: false, showSelectonBorder: false)
        }
        
        backgroundColor = ColorConstants.whiteColor
    }
    
}

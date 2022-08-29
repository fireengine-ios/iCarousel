//
//  AlbumCollectionViewCell.swift
//  Depo
//
//  Created by Oleg on 23.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class AlbumCellView: UIView {
    
    @IBOutlet weak private var selectionIcon: UIImageView!
    @IBOutlet weak private var imageView: LoadingImageView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak private var titleLabel: UILabel!{
        willSet {
            newValue.textAlignment = .left
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 12)
        }
    }
    
    @IBOutlet weak private var shadowView: UIView! {
        willSet {
            newValue.layer.shadowColor = UIColor.lightGray.cgColor
            newValue.layer.shadowOpacity = 1
            newValue.layer.shadowOffset = CGSize.zero
            newValue.layer.shadowRadius = 3
            newValue.layer.shouldRasterize = true
            newValue.layer.cornerRadius = 2
        }
    }
    
    @IBOutlet weak private var imageBorderView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 2
        }
    }
    
    private var imageGradientBorderLayer: CAGradientLayer?
    
    // MARK: - Setup
    
    func setupStyle(with displayType: BaseDataSourceDisplayingType) {
        switch displayType {
        case .greed:
            shadowView.isHidden = true
            titleLabel.textColor = AppColor.blackColor.color
            titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        case .list:
            titleLabel.textColor = ColorConstants.textGrayColor
            titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        case .faceImage:
            break
        }
    }
    
    func setup(with album: AlbumItem) {
        titleLabel.text = album.name
        imageView.loadImage(with: album.preview, smooth: false)
        
        isAccessibilityElement = true
        accessibilityTraits = .none
        accessibilityLabel = album.name
        
        layoutIfNeeded()
        
    }
    
    func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        selectionIcon.isHidden = !isSelectionActive
        selectionIcon.image = isSelected ? Image.iconCheckmarkSelected.image : Image.iconCheckmarkNotSelected.image
        imageView.set(borderIsVisible: isSelected)
    }
    
    func cancelImageLoading() {
        imageView.cancelLoadRequest()
        imageView.image = nil
    }
    
    // MARK: Gradient Image Border
    
    private func setGradient(isEnabled: Bool) {
        if isEnabled {
            setupGradientBorder()
        } else {
            imageGradientBorderLayer?.removeFromSuperlayer()
            imageGradientBorderLayer = nil
        }
    }
    
    private func setupGradientBorder() {
        guard imageGradientBorderLayer == nil else {
            return
        }
        
        let gradientBorderLayer = CAGradientLayer()
        gradientBorderLayer.frame = imageBorderView.bounds
        let colors = [ColorConstants.lightTeal, ColorConstants.apricotTwo, ColorConstants.rosePink]
        gradientBorderLayer.colors = colors.map { return $0.cgColor }
        gradientBorderLayer.startPoint = .zero
        gradientBorderLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: imageBorderView.bounds, cornerRadius: 0).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = 5
        
        gradientBorderLayer.mask = mask
        
        imageGradientBorderLayer = gradientBorderLayer

        imageBorderView.layer.addSublayer(gradientBorderLayer)
    }
}

final class AlbumCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet private weak var listView: AlbumCellView!
    @IBOutlet private weak var greedView: AlbumCellView!
    
    private func isBigSize() -> Bool {
        return frame.size.height > NumericConstants.albumCellListHeight
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        listView.setupStyle(with: .list)
        greedView.setupStyle(with: .greed)
    }
    
    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        guard let album = wrappedObj as? AlbumItem else {
            return
        }
        
        if isBigSize() {
            greedView.setup(with: album)
            
            listView.isHidden = true
            greedView.isHidden = false
        } else {
            listView.setup(with: album)
            
            listView.isHidden = false
            greedView.isHidden = true
        }
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        if isBigSize() {
            greedView.setSelection(isSelectionActive: isSelectionActive, isSelected: isSelected)
        } else {
            listView.setSelection(isSelectionActive: isSelectionActive, isSelected: isSelected)
        }
    }
    
    override func updating() {
        super.updating()
        
        if isBigSize() {
            greedView.cancelImageLoading()
        } else {
            listView.cancelImageLoading()
        }
    }
}

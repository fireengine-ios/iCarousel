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
    @IBOutlet weak var greedImageBorderView: UIView!
    
    private let kLayerNameGradientBorder = "GradientBorderLayer"
    private var imageGradientBorder: CAGradientLayer? {
        return greedImageBorderView.layer.sublayers?.first(where: { $0.name == kLayerNameGradientBorder }) as? CAGradientLayer
    }
    
    private func isBigSize() -> Bool {
        return frame.size.height > NumericConstants.albumCellListHeight
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        listViewTitle.textColor = ColorConstants.textGrayColor
        listViewTitle.font = UIFont.TurkcellSaturaRegFont(size: 18)
        
        greedViewTitle.textColor = .black
        greedViewTitle.font = UIFont.TurkcellSaturaRegFont(size: 14)
        
        greedImageBorderView.layer.cornerRadius = 2
    }
    
    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        guard let album = wrappedObj as? AlbumItem else {
            return
        }
        
        listViewTitle.text = album.name
        listViewIcon.loadThumbnail(object: album.preview, smooth: true)
        
        greedViewTitle.text = album.name
        greedViewIcon.loadThumbnail(object: album.preview, smooth: true)
        
        listView.isHidden = isBigSize()
        greedView.isHidden = !isBigSize()
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitNone
        accessibilityLabel = album.name
        
        setNeedsLayout()
        layoutIfNeeded()
        
        greedShadowView.addShadowView()
        listShadowView.addShadowView()
        
        if album.icon == "TBMatik" {
            setupGradientBorder()
        } else {
            imageGradientBorder?.removeFromSuperlayer()
        }
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        listSelectionIcon.isHidden = !isSelectionActive
        listSelectionIcon.image = UIImage(named: isSelected ? "selected" : "notSelected")
        listViewIcon.setBorderVisibility(visibility: isSelected)
        
        
        greedSelectionIcon.isHidden = !isSelectionActive
        greedSelectionIcon.image = UIImage(named: isSelected ? "selected" : "notSelected")
        greedViewIcon.setBorderVisibility(visibility: isSelected)
    }

    // MARK: Gradient Image Border
    
    private func setupGradientBorder() {
        guard imageGradientBorder == nil else {
            return
        }
        
        let border = CAGradientLayer()
        border.name = kLayerNameGradientBorder
        border.frame = greedImageBorderView.bounds
        let colors = [ColorConstants.lightTeal, ColorConstants.apricotTwo, ColorConstants.rosePink]
        border.colors = colors.map { return $0.cgColor }
        border.startPoint = .zero
        border.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: border.bounds, cornerRadius: 0).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = 10
        
        border.mask = mask

        greedImageBorderView.layer.addSublayer(border)
    }
    
}

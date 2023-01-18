//
//  CollectionViewCellForController.swift
//  Depo
//
//  Created by Oleg on 26.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CollectionViewCellForController: BaseCollectionViewCellWithSwipe {
    
    func addViewOnCell(controllersView: UIView) {
        if let baseView = controllersView as? BaseCardView {
            isSwipeEnable = baseView.canSwipe
        }
        
        controllersView.layer.cornerRadius = 15
        controllersView.clipsToBounds = true
        
        let layer = CALayer()
        layer.frame = contentView.layer.frame
        
        layer.shadowColor = AppColor.cellShadow.color.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 6
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
        layer.shouldRasterize = true
        layer.cornerRadius = 15
        
        DispatchQueue.main.async {
            self.contentView.layer.addSublayer(layer)
            self.contentView.addSubview(controllersView)
            
            controllersView.frame = self.contentView.bounds
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        
        if let sublayers = contentView.layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.layer.sublayers?.forEach {
            $0.frame = contentView.layer.frame
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
    }
    
    override func willDisplay() {
        super.willDisplay()
    }
    
    override func didEndDisplay() {
        super.didEndDisplay()
        if let controllersView = self.contentView.subviews.first as? BaseCardView {
            controllersView.viewDidEndShow()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        contentView.layer.sublayers?.first?.shadowColor = AppColor.cellShadow.color.cgColor
    }
    
}

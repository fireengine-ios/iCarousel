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
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        
        if let baseView = controllersView as? BaseView {
            isSwipeEnable = baseView.canSwipe
        }
        
        if (contentView.layer.sublayers != nil) {
            for l in contentView.layer.sublayers! {
                l.removeFromSuperlayer()
            }
        }
        
        controllersView.layer.cornerRadius = 5
        controllersView.clipsToBounds = true
        
        let layer = CALayer()
        layer.frame = CGRect(x: contentView.layer.frame.origin.x, y: contentView.layer.frame.origin.y, width: contentView.layer.frame.size.width, height: contentView.layer.frame.size.height )
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: layer.frame.size.width, height: layer.frame.size.height)).cgPath
        layer.shouldRasterize = true
        layer.cornerRadius = 5
        
        DispatchQueue.main.async {
            self.contentView.layer.addSublayer(layer)
            self.contentView.addSubview(controllersView)
            
            controllersView.frame = self.contentView.bounds
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
        if let controllersView = self.contentView.subviews.first as? BaseView {
            controllersView.viewDidEndShow()
        }
    }
    
}

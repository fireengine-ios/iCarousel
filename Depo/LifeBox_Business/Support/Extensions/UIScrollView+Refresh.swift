//
//  UIScrollView+Refresh.swift
//  PullToRefreshTest
//
//  Created by Bondar Yaroslav on 15/04/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

private var refreshBlockAssociationKey: UInt8 = 0

extension UIScrollView {
    
    typealias RefreshBlock = (_ refreshControl: UIRefreshControl) -> Void
    
    var refreshBlock: RefreshBlock? {
        get {
            return objc_getAssociatedObject(self, &refreshBlockAssociationKey) as? RefreshBlock
        }
        set {
            objc_setAssociatedObject(self, &refreshBlockAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    @discardableResult
    func addRefreshControl(title: String? = nil, color: UIColor? = nil, refreshHandler: RefreshBlock? = nil) -> UIRefreshControl {
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        if let handler = refreshHandler {
            refreshBlock = handler
        }
        
        if let title = title {
            if let color = color {
                let attr = [NSAttributedStringKey.foregroundColor: color]
                refresher.attributedTitle = NSAttributedString(string: title, attributes: attr)
                refresher.tintColor = color
            } else {
                refresher.attributedTitle = NSAttributedString(string: title)
            }
            
        } else if let color = color {
            refresher.tintColor = color
        }
        
        refreshControl = refresher
        
        return refresher
    }
    
    @objc private func refreshData(_ refreshControl: UIRefreshControl) {
        refreshBlock?(refreshControl)
    }
}

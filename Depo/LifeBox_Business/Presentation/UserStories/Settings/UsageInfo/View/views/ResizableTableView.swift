//
//  ResizableTableView.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/25/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class ResizableTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

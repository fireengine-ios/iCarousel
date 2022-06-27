//
//  ResizableScrollView.swift
//  Depo
//
//  Created by Hady on 6/24/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class ResizableScrollView: UIScrollView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

//
//  IntrinsicTextView.swift
//  Depo
//
//  Created by Harbros 3 on 1/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class IntrinsicTextView: UITextView {
    
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override func invalidateIntrinsicContentSize() {
        isScrollEnabled = false
        super.invalidateIntrinsicContentSize()
    }
    
}

//
//  TapGestureRecognizerWithClosure.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 11/29/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TapGestureRecognizerWithClosure: UITapGestureRecognizer {

    private var closure: VoidHandler?
    
    init() {
        super.init(target: self, action: #selector(runAction))
    }
    
    convenience init(closure: @escaping VoidHandler) {
        self.init()
        self.closure = closure
    }
    
    @objc private func runAction() {
        closure?()
    }
    
}

//
//  TapGestureRecognizerWithClosure.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 11/29/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class TapGestureRecognizerWithClosure: UITapGestureRecognizer {
    
    private let closure: VoidHandler
    
    init(closure: @escaping VoidHandler) {
        self.closure = closure
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(runAction))
    }
    
    @objc private func runAction() {
        closure()
    }
}

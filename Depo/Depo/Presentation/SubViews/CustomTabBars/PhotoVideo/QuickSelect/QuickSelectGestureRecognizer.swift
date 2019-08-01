//
//  QuickSelectGestureRecognizer.swift
//  Depo
//
//  Created by Konstantin Studilin on 25/07/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

final class QuickSelectGestureRecognizer: UILongPressGestureRecognizer {
    
    private var beginPoint: CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        beginPoint = touches.first?.location(in: self.view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        defer {
            super.touchesMoved(touches, with: event)
            beginPoint = nil
        }
        
        guard
            let view = view,
            let touchPoint = touches.first?.location(in: view),
            let beginPoint = beginPoint
        else {
            return
        }
        
        let deltaY = abs(beginPoint.y - touchPoint.y)
        let deltaX = abs(beginPoint.x - touchPoint.x)
        if deltaY != 0 && deltaY / deltaX > 1 {
            state = .failed
            return
        }
    }
    
}

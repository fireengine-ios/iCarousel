//
//  ExtandedTapAreaButton.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ExtendedTapAreaButton: UIButton {
    
    var extendBy: CGFloat = 10.0
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(
            x: self.bounds.origin.x - extendBy,
            y: self.bounds.origin.y - extendBy,
            width: self.bounds.size.width + 2 * extendBy,
            height: self.bounds.size.height + 2 * extendBy
        )
        return newArea.contains(point)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

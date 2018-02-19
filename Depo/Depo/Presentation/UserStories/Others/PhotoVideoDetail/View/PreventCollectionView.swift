//
//  PreventCollectionView.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PreventCollectionView: UICollectionView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancel(in: view)
        
    }
}

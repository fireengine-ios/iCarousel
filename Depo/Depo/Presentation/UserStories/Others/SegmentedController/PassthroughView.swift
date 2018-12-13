//
//  PassthroughView.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 12/13/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

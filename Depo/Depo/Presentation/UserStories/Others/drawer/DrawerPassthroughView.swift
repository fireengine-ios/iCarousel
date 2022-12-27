//
//  DrawerPassthroughView.swift
//  drawer
//
//  Created by Hady on 6/11/22.
//

import Foundation
import UIKit

class DrawerPassthroughView: UIView {
    var passthroughView: UIView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        if view == self {
            view = passthroughView?.hitTest(point, with: event)
        }

        return view
    }
}

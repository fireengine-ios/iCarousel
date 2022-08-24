//
//  DrawerTransitioningDelegate.swift
//  drawer
//
//  Created by Hady on 6/11/22.
//

import UIKit

class DrawerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    static let instance = DrawerTransitioningDelegate()

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        DrawerPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        DrawerAnimationController(transitionStyle: .presentation)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        DrawerAnimationController(transitionStyle: .dismissal)
    }
}

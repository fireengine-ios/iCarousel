//
//  DrawerAnimationController.swift
//  Depo
//
//  Created by Hady on 6/14/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class DrawerAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    enum TransitionStyle {
        case presentation
        case dismissal
    }

    private enum Constants {
        static let duration: TimeInterval = 0.3
        static let springDamping: CGFloat = 1
        static let initialSpringVelocity: CGFloat = 0.5
    }

    private let transitionStyle: TransitionStyle

    required init(transitionStyle: TransitionStyle) {
        self.transitionStyle = transitionStyle
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        Constants.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitionStyle {
        case .presentation:
            animatePresentation(transitionContext: transitionContext)
        case .dismissal:
            animateDismissal(transitionContext: transitionContext)
        }
    }

    private func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? DrawerViewController else {
            return
        }

        let drawerView: UIView = toVC.view
        drawerView.frame = transitionContext.finalFrame(for: toVC)
        drawerView.transform = .init(translationX: 0, y: drawerView.frame.height)
        transitionContext.containerView.addSubview(drawerView)

        toVC.layoutDrawerContentViewBeforePresenting()

        UIView.animate(
            withDuration: Constants.duration,
            delay: 0,
            usingSpringWithDamping: Constants.springDamping,
            initialSpringVelocity: Constants.initialSpringVelocity,
            options: [.allowUserInteraction],
            animations: {
                drawerView.transform = .identity
            },
            completion: { didComplete in
                transitionContext.completeTransition(didComplete)
            }
        )
    }

    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from)
            else { return }

        let drawerView: UIView = fromVC.view

        UIView.animate(
            withDuration: Constants.duration,
            delay: 0,
            usingSpringWithDamping: Constants.springDamping,
            initialSpringVelocity: Constants.initialSpringVelocity,
            options: [.allowUserInteraction],
            animations: {
                drawerView.transform = .init(translationX: 0, y: drawerView.frame.height)
            },
            completion: { didComplete in
                transitionContext.completeTransition(didComplete)
            }
        )
    }
}

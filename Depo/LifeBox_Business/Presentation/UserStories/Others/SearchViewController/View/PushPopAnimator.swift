//
//  PushPopAnimator.swift
//  Depo
//
//  Created by Andrei Novikau on 22/02/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PushPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting: Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromController = transitionContext.viewController(forKey: .from),
            let toController = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        toController.view.alpha = 0
        toController.view.frame = fromController.view.frame
        
        let container = transitionContext.containerView
        let animationView = presenting ? toController.view : fromController.view
        
        if presenting {
            container.addSubview(animationView!)
        }
    
        UIView.animate(withDuration: 0.35, animations: {
            toController.view.alpha = 1
            if !self.presenting {
                fromController.view.alpha = 0
            }
        }, completion: { completed in
            let cancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!cancelled)

            if self.presenting, toController.navigationController != nil {
                container.insertSubview(fromController.view, belowSubview: toController.view)
            } else if fromController.navigationController != nil, cancelled {
                container.insertSubview(toController.view, belowSubview: fromController.view)
            }
        })
    }
}

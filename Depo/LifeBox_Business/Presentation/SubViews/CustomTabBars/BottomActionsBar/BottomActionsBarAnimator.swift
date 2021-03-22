//
//  BottomActionsBarAnimator.swift
//  Depo
//
//  Created by Konstantin Studilin on 12.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation


final class BottomActionsBarAnimator {
    private let height: CGFloat = 60
    private let originalX: CGFloat = 0
    private lazy var originalY = -self.height
    
    private weak var sourceView: UIView?
    private weak var barView: UIView?
    
    private var animations = [VoidHandler]()
    
    init(barView: UIView) {
        self.barView = barView
    }
    
    func hide(animated: Bool) {
        let animationDuration = animated ? NumericConstants.animationDuration : 0
        addHideAnimationBlock(duration: animationDuration)
    }
    
    func show(onSourceView: UIView, animated: Bool) {
        self.sourceView = onSourceView
        let animationDuration = animated ? NumericConstants.animationDuration : 0
        addShowAnimationBlock(duration: animationDuration)
    }
    
    func updateLayout(animated: Bool) {
        guard let view = barView, let sourceView = view.superview else {
            return
        }
        
        let sourceViewSize = sourceView.frame.size
        
        view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y,
                            width: sourceViewSize.width, height: view.frame.size.height)
    }
    
    
    // MARK: - Private
    
    private func addHideAnimationBlock(duration: TimeInterval) {
        let animationBlock = { [weak self] in
            guard let self = self, let view = self.barView else {
                return
            }
            
            let newY = view.frame.origin.y - self.originalY + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            
            UIView.animate(withDuration: duration, animations: {
                view.frame.origin = CGPoint(x: 0, y: newY)
            }, completion: { _ in
                view.removeFromSuperview()
                self.nextAnimation()
            })
        }
        
        animations.append(animationBlock)
        
        if animations.count == 1 {
            animationBlock()
        }
    }
    
    private func addShowAnimationBlock(duration: TimeInterval) {
        let animationBlock = { [weak self] in
            guard let self = self, let view = self.barView else {
                return
            }
            
            guard let sourceView = self.sourceView, view.superview == nil else {
                self.nextAnimation()
                return
            }
            
            sourceView.addSubview(view)
            sourceView.bringSubview(toFront: view)
            
            let sourceViewSize = sourceView.frame.size
            
            view.frame = CGRect(x: self.originalX, y: sourceViewSize.height - self.originalY,
                                width: sourceViewSize.width, height: self.height)
            
            var newY = sourceViewSize.height - self.height
            
            let newTempOrigin = CGPoint(x: 0, y: newY)
            let windowOrigin = sourceView.convert(newTempOrigin, to: nil)
            
            if
                let bottomSafeInsetY = UIApplication.shared.keyWindow?.safeAreaInsets.bottom,
                bottomSafeInsetY > 0,
                windowOrigin.y + self.height > bottomSafeInsetY
            {
                newY -= bottomSafeInsetY
            }
            
            UIView.animate(withDuration: duration, animations: {
                view.frame.origin = CGPoint(x: 0, y: newY)
                
            }, completion: { _ in
                self.nextAnimation()
            })
        }
        
        animations.append(animationBlock)
        
        if animations.count == 1 {
            animationBlock()
        }
    }
    
    private func nextAnimation() {
        //TODO: refactor logic, copypasted from EditinglBar
        if animations.count > 1 {
            if let lastBlock = animations.last {
                animations = [lastBlock]
                lastBlock()
            }
        } else {
            animations.removeAll()
        }
    }
}

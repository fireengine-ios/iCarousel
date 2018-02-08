//
//  FloatingView.swift
//  Depo
//
//  Created by Aleksandr on 7/17/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class FloatingView: UIViewController, UIPopoverPresentationControllerDelegate {
    
    let shadowView = UIView()
    
    var currentContentView: UIView?
    
    private var visibleOriginalY: CGFloat = 0
    private var hiddenOriginalFrame = CGRect()
    
    func dismissView() {
        
        removeShadowView(animated: true)
        if !Device.isIpad {
            changeViewState(animated: true)
        }
    }
    
    private func removeShadowView(animated: Bool) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.shadowView.alpha = 0
        }, completion: { _ in
            self.shadowView.removeFromSuperview()
        })
        
    }
    
    func hideView(animated: Bool) {
        if !Device.isIpad {
             changeViewState(animated: animated)
        } else {
            self.dismiss(animated: true, completion: {
                self.dismissView()
            })
        }
    }
    
    private func changeViewState(animated: Bool) {
        shadowView.isHidden = !shadowView.isHidden
        if animated {
            animateViewWholeHeightVerticaly()
        } else {
            changeCurrentYPositionsToPrevious()
        }
    }

    @objc private func shadowViewGotTouched(sender: Any) {
        dismissView()
    }
    
    private func getEndYViewPositionFrame() -> CGRect {
        let originalY = view.frame.origin.y
        var endY: CGFloat = -view.frame.size.height
        if originalY < 0 {
            endY = visibleOriginalY // navBarSize
        }
        return CGRect(x: 0, y: endY, width: hiddenOriginalFrame.size.width, height: hiddenOriginalFrame.size.height)
    }
    
    private func changeCurrentYPositionsToPrevious() {
        self.view.frame = getEndYViewPositionFrame()
    }
    
    private func animateViewWholeHeightVerticaly() {
        let endFrame = getEndYViewPositionFrame()

        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.frame = endFrame
        }, completion: { _ in
            if endFrame.origin.y < 0 {
                self.view.removeFromSuperview()
                self.currentContentView?.removeFromSuperview()
                self.currentContentView = nil
                self.shadowView.removeFromSuperview()
            }
        })
    }
    
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        dismissView()
        return true
    }
    
}

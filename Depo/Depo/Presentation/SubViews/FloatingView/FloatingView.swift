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
    private let statusBarHeightSize: CGFloat = 20
    private var hiddenOriginalFrame = CGRect()
    
    
    private func setupFloatingView(contentView: UIView, animated: Bool, popUpSize: CGSize, arrowDirection: UIPopoverArrowDirection, sourceRect: CGRect, onViewController sourceViewController: UIViewController) {
        
        visibleOriginalY = (sourceViewController.navigationController?.navigationBar.frame.size.height ?? 0) + statusBarHeightSize
        
        view.frame = CGRect(x: 0, y: visibleOriginalY, width: popUpSize.width, height: popUpSize.height)
 
        setupShadowView(onViewController: sourceViewController)
        
        if Device.isIpad {
            modalPresentationStyle = .popover
            preferredContentSize = CGSize(width: popUpSize.width, height: popUpSize.height)
            popoverPresentationController?.sourceRect = sourceRect
            popoverPresentationController?.sourceView = sourceViewController.view
            popoverPresentationController?.permittedArrowDirections = arrowDirection
            popoverPresentationController?.delegate = self
            
        } else {
            
            if view.superview == nil {
                
                hiddenOriginalFrame = CGRect(x: 0, y: -popUpSize.height, width: sourceViewController.view.bounds.width, height: popUpSize.height)
                view.frame = hiddenOriginalFrame
                sourceViewController.view.addSubview(self.view)
            }
        }
        
        if currentContentView == nil {
            contentView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
            view.addSubview(contentView)
            currentContentView = contentView
        }
        
    }
    
    private func setupShadowView(onViewController viewcontroller: UIViewController) {
        if shadowView.superview != nil {
            return
        }
        shadowView.frame = viewcontroller.view.bounds
        shadowView.backgroundColor = UIColor.black
        shadowView.alpha = 0.6
        
        shadowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shadowViewGotTouched(sender:))))
        
        viewcontroller.view.addSubview(shadowView)
        shadowView.isHidden = true
    }
    
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
    
    func showView(contentView: UIView, animated: Bool, popUpSize: CGSize, arrowDirection: UIPopoverArrowDirection, sourceRect: CGRect, onViewController sourceViewController: UIViewController) {
        
        setupFloatingView(contentView: contentView, animated: animated, popUpSize: popUpSize, arrowDirection: arrowDirection, sourceRect: sourceRect, onViewController: sourceViewController)
        
        if Device.isIpad {
            sourceViewController.present(self, animated: animated, completion: {
                self.shadowView.isHidden = !self.shadowView.isHidden
            })
        } else {
            changeViewState(animated: animated)
        }
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

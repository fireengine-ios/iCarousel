//
//  PassThroughView.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 12/13/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PassThroughViewDelegate: class {
    func handlePan(recognizer:UIPanGestureRecognizer)
    func handleSwipe(recognizer:UISwipeGestureRecognizer)
}


final class PassThroughView: UIView {
    
    weak var delegate: PassThroughViewDelegate?
        
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler))
        gesture.delegate = self
        return gesture
    }()
    
    private lazy var swipeGestureRecognizerRight: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer(target: self, action:
            #selector(swipeGestureRecognizerHandler))
        gesture.delegate = self
        gesture.direction = .right
        return gesture
    }()
    
    private lazy var swipeGestureRecognizerLeft: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer(target: self, action:
            #selector(swipeGestureRecognizerHandler))
        gesture.delegate = self
        gesture.direction = .left
        return gesture
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGestureRecognizers()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        }
        return hitView
    }
    
    func enableGestures() {
        swipeGestureRecognizerRight.isEnabled = true
        swipeGestureRecognizerLeft.isEnabled = true
        panGestureRecognizer.isEnabled = true
    }
    
    func disableGestures() {
        swipeGestureRecognizerRight.isEnabled = false
        swipeGestureRecognizerLeft.isEnabled = false
        panGestureRecognizer.isEnabled = false
    }
    
    @objc private func panGestureRecognizerHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        delegate?.handlePan(recognizer: gestureRecognizer)
    }
    
    @objc private func swipeGestureRecognizerHandler(_ gestureRecognizer: UISwipeGestureRecognizer) {
        delegate?.handleSwipe(recognizer: gestureRecognizer)
    }
    
    private func addGestureRecognizers() {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow  else {
            assertionFailure()
            return
        }
        window.addGestureRecognizer(panGestureRecognizer)
        window.addGestureRecognizer(swipeGestureRecognizerRight)
        window.addGestureRecognizer(swipeGestureRecognizerLeft)
    }
    
}

extension PassThroughView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        /// handle right-left swipes first
        return otherGestureRecognizer is UISwipeGestureRecognizer && gestureRecognizer is UIPanGestureRecognizer
    }
}

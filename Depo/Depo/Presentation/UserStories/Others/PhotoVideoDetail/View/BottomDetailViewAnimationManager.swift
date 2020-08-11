//
//  BottomDetailViewAnimationManager.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/4/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum CardState {
    case expanded
    case collapsed
    case full
    
    var isFull: Bool {
        return self == .full
    }
    
    var isCollapsed: Bool {
        return self == .collapsed
    }
    
    var isExpanded: Bool {
        return self == .expanded
    }
}

protocol BottomDetailViewAnimationManagerDelegate {
    func getSelectedIindex() -> Int
    func getObjectsCount() -> Int
    func getIsFullScreenState() -> Bool
    
    func setIsFullScreenState(_ isFullScreen: Bool)
    func setSelectedIndex(_ selectedIndex: Int)
}

protocol BottomDetailViewAnimationManagerProtocol {
    var managedView: FileInfoView { get }
    func closeDetailView()
    func getCurrenState() -> CardState
    func showDetailView()
    func updatePassThroughViewDelegate(passThroughView: PassThroughView?)
}

final class BottomDetailViewAnimationManager: BottomDetailViewAnimationManagerProtocol {
    
    private(set) var managedView: FileInfoView
    private let collectionView: UICollectionView
    private let passThrowView: PassThroughView
    private let view: UIView
    private let collapseView: UIView
        
    private var isFullScreen: Bool {
        get {
            delegate.getIsFullScreenState()
        }
        set {
            delegate.setIsFullScreenState(newValue)
        }
    }
    
    private var selectedIndex: Int {
        get {
            delegate.getSelectedIindex()
        }
        set {
            delegate.setSelectedIndex(newValue)
        }
    }
    
    var delegate: BottomDetailViewAnimationManagerDelegate

    private var viewState: CardState = .collapsed
    private var gestureBeginLocation: CGPoint = .zero
    private var dragViewBeginLocation: CGPoint = .zero
    private let cardHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    
    init(managedView: FileInfoView, passThrowView: PassThroughView, collectionView: UICollectionView, collapseView: UIView, parentView: UIView, delegate: BottomDetailViewAnimationManagerDelegate) {
        self.collectionView = collectionView
        self.managedView = managedView
        self.passThrowView = passThrowView
        self.view = parentView
        self.collapseView = collapseView
        self.delegate = delegate
        passThrowView.delegate = self
        collapseViewSetup()
    }
    
    private lazy var imageMaxY: CGFloat = {
        return UIScreen.main.bounds.height - getCellMaxY()
    }()
    
    private var detailViewIsHidden = true {
        didSet {
            if detailViewIsHidden != oldValue {
                setupDetailViewAlpha(isHidden: detailViewIsHidden)
            }
        }
    }
    
    func updatePassThroughViewDelegate(passThroughView: PassThroughView?) {
        passThroughView?.delegate = self
    }
    
    private func collapseViewSetup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeDetailView))
        collapseView.addGestureRecognizer(tap)
        collapseView.isHidden = true
        collapseView.layer.cornerRadius = 15
    }
    
    func getCurrenState() -> CardState {
        return viewState
    }
    
    private func needHideDetailView() -> Bool {

        return managedView.frame.minY >= view.frame.height * 0.8
    }
    
    private func getCellMaxY() -> CGFloat {
        collectionView.cellForItem(at: IndexPath(row: selectedIndex, section: .zero))?.frame.maxY ?? .zero
    }
    
    private func setupDetailViewAlpha(isHidden: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.managedView.alpha = isHidden ? 0 : 1
        }
    }
}

extension BottomDetailViewAnimationManager: PassThroughViewDelegate {
    
    func tapGesture(recognizer: UITapGestureRecognizer) {
        closeDetailView()
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
        let coef = (view.frame.height * 0.9 - view.frame.height * 0.80)
        
        switch recognizer.state {
        case .began:
            
            managedView.hideKeyboard()
            gestureBeginLocation = recognizer.location(in: view)
            dragViewBeginLocation = collectionView.frame.origin
        case .changed:
            
            let newLocation = dragViewBeginLocation.y + (recognizer.location(in: view).y - gestureBeginLocation.y)
            
            if newLocation > 0 {
                recognizer.state = .cancelled
                setCollapsedState()
                return
            }

            isFullScreen = true
            collectionView.frame.origin.y = newLocation
            
            if abs(newLocation) < coef {
                managedView.alpha = max(0, min(1, abs(newLocation / coef)))
                managedView.frame.origin.y = collectionView.frame.maxY - imageMaxY + max(0, coef - coef * abs(newLocation / coef))
                return
            }
            
            managedView.frame.origin.y = collectionView.frame.maxY - imageMaxY
            
        case .ended:
            dissableTouchUntillFinish(isDisabled: true)
            UIView.animate(withDuration: 0.3, animations: {
                self.positionForView(velocityY: recognizer.velocity(in: self.managedView).y)
            }, completion: { _ in
                switch self.viewState {
                case .collapsed:
                    self.setCollapseStateAnimatedly()
                case .expanded:
                    self.setExpandedState()
                case .full:
                    self.setFullState()
                }
                self.dissableTouchUntillFinish(isDisabled: false)
            })
        default:
            break
        }
    }
    
    private func dissableTouchUntillFinish(isDisabled: Bool) {
        if isDisabled {
            passThrowView.isUserInteractionEnabled = false
            passThrowView.disableGestures()
        } else {
            passThrowView.isUserInteractionEnabled = true
            passThrowView.enableGestures()
        }
    }
    
    func positionForView(velocityY: CGFloat) {
        
        let detailViewExpandedPositionY = view.frame.height - cardHeight
        let expandedRange = ((UIScreen.main.bounds.height * 0.15)...(UIScreen.main.bounds.height * 0.45))
    
        if velocityY > 50, viewState.isFull {
            setExpandedState()
        } else if velocityY > 50 {
            setCollapseStateAnimatedly()
        } else if velocityY < -50, managedView.frame.origin.y > detailViewExpandedPositionY, !viewState.isExpanded  {
            setExpandedState()
        } else if managedView.frame.origin.y < detailViewExpandedPositionY {
            setFullState()
        } else if expandedRange.contains(managedView.frame.origin.y) {
            setExpandedState()
        } else if managedView.frame.origin.y > view.frame.height {
            setCollapseStateAnimatedly()
        } else {
            switch self.viewState {
            case .collapsed:
                setCollapseStateAnimatedly()
            case .expanded:
                setExpandedState()
            case .full:
                setFullState()
            }
        }
    }
}

extension BottomDetailViewAnimationManager {
    
    @objc func closeDetailView() {
        managedView.hideKeyboard()
        viewState = .collapsed
        
        UIView.animate(withDuration: 0.5, animations: {
                        self.collectionView.frame.origin.y = .zero
                        self.managedView.frame.origin.y = self.collectionView.frame.maxY - self.imageMaxY
                        self.collapseView.isHidden = true
        }, completion: { _ in
            self.setupDetailViewAlpha(isHidden: true)
            self.managedView.frame.origin.y = self.view.frame.height
            self.isFullScreen = false
        })
    }
    
    private func setCollapseStateAnimatedly() {
        
        managedView.hideKeyboard()
        viewState = .collapsed
        
        UIView.animate(withDuration: 0.1, animations: {
            self.collectionView.frame.origin.y = .zero
            self.managedView.frame.origin.y = self.collectionView.frame.maxY - self.imageMaxY
            self.collapseView.isHidden = true
        }) { _ in
            self.setupDetailViewAlpha(isHidden: true)
            self.managedView.frame.origin.y = self.view.frame.height
            self.isFullScreen = false
        }
    }
    
    private func setCollapsedState() {
        managedView.hideKeyboard()
        viewState = .collapsed
        isFullScreen = false
        collapseView.isHidden = true
        setupDetailViewAlpha(isHidden: true)
        managedView.frame.origin.y = self.view.frame.height
    }
    
    private func setExpandedState() {
        view.layoutIfNeeded()
        isFullScreen = true
        collapseView.isHidden = false
        setupDetailViewAlpha(isHidden: false)
        let yPositionForBottomView = view.frame.height - cardHeight
        let collectionViewCellMaxY = getCellMaxY()
        viewState = .expanded
        managedView.frame.origin.y = yPositionForBottomView
        collectionView.frame.origin.y = yPositionForBottomView - collectionViewCellMaxY + imageMaxY
        stopVideoIfNeeded()
    }
    
    private func setFullState() {
        view.layoutIfNeeded()
        let collectionViewCellMaxY = getCellMaxY()
        viewState = .full
        managedView.frame.origin.y = .zero
        collectionView.frame.origin.y = -collectionViewCellMaxY + imageMaxY
        collapseView.isHidden = false
        setupDetailViewAlpha(isHidden: false)
        isFullScreen = true
    }
    
    private func stopVideoIfNeeded() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: .zero)) as? VideoInterruptable {
            cell.stop()
        }
    }
    
    func showDetailView() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.isFullScreen = true
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 0.3,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.9,
                           options: [.curveEaseInOut, .allowUserInteraction],
                           animations: {
                            self.viewState = .expanded
                            self.collectionView.frame.origin.y = self.view.frame.minY - (self.cardHeight - self.imageMaxY)
                            self.managedView.frame.origin.y = self.collectionView.frame.maxY - self.imageMaxY
                            self.collapseView.isHidden = false
                            self.setupDetailViewAlpha(isHidden: false)
            }, completion: nil)
        }
    }
}

//MARK: Scroll implementation here
extension BottomDetailViewAnimationManager {
        
    func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        switch (recognizer.state, recognizer.direction) {
        case (.ended, .left):
            scrollLeft()
        case (.ended, .right):
            scrollRight()
        default:
            return
        }
    }
    
    private func scrollRight() {
        let newIndex = selectedIndex - 1
        scroll(to: newIndex)
    }
    
    private func scrollLeft() {
        let newIndex = selectedIndex + 1
        scroll(to: newIndex)
    }

    private func scroll(to index: Int) {
        guard 0..<delegate.getObjectsCount() ~= index else {
            return
        }
        
        let cell = collectionView.visibleCells.first as? CellConfigurable
        cell?.responder = self
        let offsetY = collectionView.contentOffset.y
        selectedIndex = index
        
        let newContentOffsetX = collectionView.bounds.size.width * CGFloat(index)
        let newContentOffset = CGPoint(x: newContentOffsetX, y: offsetY)
        collectionView.setContentOffset(newContentOffset, animated: true)
        
        view.layoutIfNeeded()
    }
}


extension BottomDetailViewAnimationManager: PhotoVideoDetailCellDelegate {
    func tapOnSelectedItem() {}
    func tapOnCellForFullScreen() {}
    
    func imageLoadingFinished() {
        let yPositionForBottomView = view.frame.height - cardHeight
        let collectionViewCellMaxY = getCellMaxY()
        collectionView.frame.origin.y = yPositionForBottomView - collectionViewCellMaxY + imageMaxY
    }
}

//
//  AllFilesViewController.swift
//  Depo
//
//  Created by Alex Developer on 25.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

final class AllFilesViewController: BaseFilesGreedChildrenViewController {
    
    private let sharedFilesManager = SharedFilesCollectionManager()
    private let sharedSliderHeight: CGFloat = 224
    
    override func setupInitialState() {
        super.setupInitialState()
        checkPrivateShareSliderAvailability()
    }
    
    private func checkPrivateShareSliderAvailability() {
        sharedFilesManager.checkSharedWithMe { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.addPrivateShareSlider()
                }
            case .failed(_):
                break
            }
        }
    }
    
    private func addPrivateShareSlider() {
        
        let containerView = sharedFilesManager.sharedFilesSlider
        collectionView.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraintsArray = [NSLayoutConstraint]()

        let height = cardsContainerView.frame.size.height + containerView.frame.size.height
      
        self.collectionView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 25, right: 0)
        let topOffset = CGPoint(x: 0, y: 0 - height)
        collectionView.setContentOffset(topOffset , animated: false)
        collectionView.updateConstraints()

        constraintsArray.append(NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 0))
        
        if let yConstr = self.contentSliderTopY {
            yConstr.constant = -height
        }
        if let hConstr = self.contentSliderH {
            hConstr.constant = height
        }

        collectionView.updateConstraints()
        
        constraintsArray.append(NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        
        refresherY =  -height + 30
        updateRefresher()
        
        noFilesViewCenterOffsetConstraint.constant = BaseFilesGreedViewController.sliderH / 2
        
        NSLayoutConstraint.activate(constraintsArray)
        sharedFilesManager.delegate = self
        
        view.layoutSubviews()
    }
    
    override func onUpdateViewForPopUpH(h: CGFloat) {

        let originalPoint = collectionView.contentOffset
        let sliderH: CGFloat =   sharedFilesManager.sharedFilesSlider.frame.size.height
        
        let calculatedH = h + sliderH
        
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            if let yConstr = self.contentSliderTopY {
                yConstr.constant = -calculatedH
            }
            if let hConstr = self.contentSliderH {
                hConstr.constant = calculatedH//h
            }
            
            self.view.layoutIfNeeded()
            self.collectionView.contentInset = UIEdgeInsets(top: calculatedH, left: 0, bottom: 25, right: 0)
        }) { [weak self] (flag) in
            guard let self = self else {
                return
            }
            
            if originalPoint.y > 1.0 {
                self.collectionView.contentOffset = originalPoint
            } else {
                self.collectionView.contentOffset = CGPoint(x: 0.0, y: -self.collectionView.contentInset.top)
            }
        }
        
        refresherY = -calculatedH + 30
        updateRefresher()
    }
}

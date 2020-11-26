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
                self.addPrivateShareSlider()
            case .failed(_):
                break
            }
        }
    }
    
    private func addPrivateShareSlider() {
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        let containerView = sharedFilesManager.sharedFilesSlider
        
        collectionView.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
//        containerView.layoutSubviews()
        self.view.layoutSubviews()
        
        var constraintsArray = [NSLayoutConstraint]()
        let privateShareSliderTopY = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: cardsContainerView, attribute: .bottom, multiplier: 1, constant: 0)
        
        let height = cardsContainerView.frame.size.height + containerView.frame.size.height + BaseFilesGreedViewController.sliderH
        if let yConstr = self.contentSliderTopY {
            yConstr.constant = -height
        }
        collectionView.updateConstraints()
        
        constraintsArray.append(privateShareSliderTopY)
        constraintsArray.append(NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        
        refresherY =  -height + 30
        updateRefresher()
        
        noFilesViewCenterOffsetConstraint.constant = BaseFilesGreedViewController.sliderH / 2
        
        
        NSLayoutConstraint.activate(constraintsArray)
        sharedFilesManager.delegate = self
    }
    
}

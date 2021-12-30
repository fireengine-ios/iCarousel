//
//  AllFilesViewController.swift
//  Depo
//
//  Created by Alex Developer on 25.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

final class AllFilesViewController: BaseFilesGreedChildrenViewController {
    
    private let sharedFilesManager = PrivateShareSliderFilesCollectionManager()
    
    private var isSliderSetuped = false
    
    private var lastCardContainerHeight: CGFloat = 0
    private let sortAreaHeight: CGFloat = 36
    private lazy var dragAndDropHelper = DragAndDropHelper.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.addInteraction(UIDropInteraction(delegate: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleShareSliderReload()
    }
    
    override func setupUnderNavBarBar(withConfig config: GridListTopBarConfig) {
        guard let unwrapedTopBar = underNavBarBar, let topBar = unwrapedTopBar.view else {
            return
        }
        
        unwrapedTopBar.setupWithConfig(config: config, centeredContent: true)
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(topBar)
        topBar.bottomAnchor.constraint(equalTo: collectionView.topAnchor).activate()
        topBar.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).activate()
        topBar.widthAnchor.constraint(equalTo: collectionView.widthAnchor).activate()
        floatingHeaderContainerHeightConstraint = topBar.heightAnchor.constraint(equalToConstant: sortAreaHeight)
        floatingHeaderContainerHeightConstraint.activate()
        calculatedUnderNavBarBarHeight = sortAreaHeight
        setupInitialPrivateShareSlider()
    }
    
    private func setupInitialPrivateShareSlider() {
        
        let containerView = sharedFilesManager.sharedFilesSlider
        collectionView.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        sharedFilesManager.delegate = self
        sharedFilesManager.changeSliderVisability(isHidden: true)
        
        var constraintsArray = [NSLayoutConstraint]()
        constraintsArray.append(NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: -calculatedUnderNavBarBarHeight))
        constraintsArray.append(NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        
        NSLayoutConstraint.activate(constraintsArray)
        
        isSliderSetuped = true
    }
    
    private func refreshSharedSliderPosition() {
        let height: CGFloat = lastCardContainerHeight + sharedFilesManager.sharedFilesSlider.frame.size.height + calculatedUnderNavBarBarHeight
        
        collectionView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 25, right: 0)
        let topOffset = CGPoint(x: 0, y: -height)
        collectionView.setContentOffset(topOffset , animated: false)
        
        if let yConstr = self.contentSliderTopY {
            yConstr.constant = -height
        }
        if let hConstr = self.contentSliderH {
            hConstr.constant = height
        }
        
        refresherY = -height + 30
        updateRefresher()
        
        noFilesViewCenterOffsetConstraint.constant = BaseFilesGreedViewController.sliderH / 2
        
        collectionView.updateConstraints()
        view.layoutSubviews()
        
    }
    
    override func onUpdateViewForPopUpH(h: CGFloat) {
        lastCardContainerHeight = h
        
        let originalPoint = collectionView.contentOffset
        var sliderH: CGFloat = 0
        
        if !sharedFilesManager.sharedFilesSlider.isHidden {
            sliderH = sharedFilesManager.sharedFilesSlider.frame.size.height
        }
        
        let calculatedH = h + sliderH + calculatedUnderNavBarBarHeight
        
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            if let yConstr = self.contentSliderTopY {
                yConstr.constant = -calculatedH
            }
            if let hConstr = self.contentSliderH {
                hConstr.constant = calculatedH
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
    
    @objc override func loadData() {
        guard isRefreshAllowed else {
            return
        }
        if !output.isSelectionState() {
            output.onReloadData()
            contentSlider?.reloadAllData()
            handleShareSliderReload()
        } else {
            refresher.endRefreshing()
        }
    }
    
    private func handleShareSliderReload() {
        guard isSliderSetuped else {
            return
        }
        sharedFilesManager.reloadData { [weak self] result in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.sharedFilesManager.changeSliderVisability(isHidden: false)
                case .failed(_):
                    self.sharedFilesManager.changeSliderVisability(isHidden: true)
                }
                self.refreshSharedSliderPosition()
            }
        }
    }
}

extension AllFilesViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: DragAndDropAllFilesType.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        DragAndDropHelper.shared.performDrop(with: session, itemType: DragAndDropAllFilesType.self)
    }
}

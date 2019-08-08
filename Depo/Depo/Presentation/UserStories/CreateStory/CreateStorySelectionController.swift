//
//  CreateStoryController.swift
//  Depo
//
//  Created by Raman Harhun on 6/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class CreateStorySelectionController: BaseViewController, ControlTabBarProtocol {
    
    internal var selectedItems = [SearchItemResponse]() {
        willSet {
            DispatchQueue.main.async {
                self.containerView?.analyzeButton.isHidden = newValue.isEmpty
            }
        }
    }
    
    internal var selectionState: PhotoSelectionState = .selecting
    
    private var selectingLimit = NumericConstants.createStoryImagesCountLimit
    private var isFavouritePictures: Bool = false

    private let navTitle: String
    
    var selectionDelegate: InstaPickSelectionSegmentedControllerDelegate?
    
    private var containerView: InstaPickSelectionSegmentedView? {
        return self.view as? InstaPickSelectionSegmentedView
    }
    
    //MARK: lifecycle
    init(title: String, isFavouritePictures: Bool) {
        navTitle = title
        self.isFavouritePictures = isFavouritePictures
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        navTitle = TextConstants.createStory

        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        let reachedLimitText = TextConstants.instapickSelectionAnalyzesLeftMax
        self.view = InstaPickSelectionSegmentedView(buttonText: TextConstants.createStoryPhotosContinue,
                                                    maxReachedText: String(format: reachedLimitText, selectingLimit),
                                                    needShowSegmentedControll: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setup()
    }
    
    //MARK: Utility Mathods
    private func setup() {
        addChildVC()
        
        setupNavigation()
        
        containerView?.analyzeButton.addTarget(self, action: #selector(openStorySetup), for: .touchUpInside)
        
        let analyticsService = AnalyticsService()
        analyticsService.logScreen(screen: .createStoryPhotosSelection)
    }
    
    private func setupNavigation() {
        
        hideTabBar()
        
        navigationBarWithGradientStyle()
        
        setTitle(withString: navTitle)
        
        let cancelButton = UIBarButtonItem(title: TextConstants.cancel, target: self, selector: #selector(hideController))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    private func addChildVC() {
        let dataSource: PhotoSelectionDataSourceProtocol = isFavouritePictures ? FavoritePhotosSelectionDataSource(pageSize: 100) : AllPhotosSelectionDataSource(pageSize: 100)

        let childController = PhotoSelectionController(title: "",
                                                       selectingLimit: selectingLimit,
                                                       delegate: self,
                                                       dataSource: dataSource)
        selectionDelegate = childController
        addChildViewController(childController)
        containerView?.containerView.addSubview(childController.view)
        childController.view.frame = containerView?.containerView.bounds ?? .zero
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        childController.didMove(toParentViewController: self)
    }
    
    private func updateScreen() {
        var navigationTitle = navTitle
        
        let selectedItemsCount = selectedItems.count
        if selectedItemsCount > 0 {
            navigationTitle = String(format: TextConstants.createStoryPhotosSelected, selectedItemsCount)
        }
        
        setTitle(withString: navigationTitle)
        
        containerView?.analyzesLeftLabel.isHidden = (selectionState != .ended)
        
        selectionDelegate?.selectionStateDidChange(selectionState)
    }
    
    //MARK: Actions
    @objc private func hideController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func openStorySetup() {
        let controller = CreateStoryViewController(images: selectedItems.map { return Item(remote: $0) })
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - PhotoSelectionControllerDelegate
extension CreateStorySelectionController: PhotoSelectionControllerDelegate {
    
    func selectionController(_ controller: PhotoSelectionController, didSelectItem item: SearchItemResponse) {
        
        selectedItems.append(item)
        
        let selectedCount = selectedItems.count
        let isReachedLimit = (selectedCount == selectingLimit)
        
        selectionState = isReachedLimit ? .ended : .selecting
        selectionDelegate?.didSelectItem(item)
    
        updateScreen()
    }
    
    func selectionController(_ controller: PhotoSelectionController, didDeselectItem item: SearchItemResponse) {
        /// not working "selectedItems.remove(item)"
        for index in (0..<selectedItems.count).reversed() where selectedItems[index] == item {
            selectedItems.remove(at: index)
        }
        
        selectionState = .selecting
        selectionDelegate?.didDeselectItem(item)
        
        updateScreen()
    }
}

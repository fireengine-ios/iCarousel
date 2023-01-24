//
//  CreateStoryController.swift
//  Depo
//
//  Created by Raman Harhun on 6/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CreateStorySelectionController: BaseViewController {
    
    var selectedItems = [SearchItemResponse]() {
        willSet {
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = !newValue.isEmpty
            }
        }
    }
    
    var selectionState: PhotoSelectionState = .selecting
    private var selectingLimit = NumericConstants.createStoryImagesCountLimit
    private var isFavouritePictures: Bool = false
    private let navTitle: String
    var selectionDelegate: InstaPickSelectionSegmentedControllerDelegate?
    
    private var containerView: CreateStorySelectionView? {
        return self.view as? CreateStorySelectionView
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
        self.view = CreateStorySelectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setup()
        updateScreen()
    }
    
    private func setup() {
        addChildVC()
        setupNavigation()
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.CreateStoryPhotoSelectionScreen())
        let analyticsService = AnalyticsService()
        analyticsService.logScreen(screen: .createStoryPhotosSelection)
    }

    private func setupNavigation() {
        setTitle(withString: navTitle)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.createStoryPhotosContinue,
                                                            target: self,
                                                            selector: #selector(openStorySetup))
        
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: UIFont.appFont(.regular, size: 17),                                  .foregroundColor: AppColor.label.color], for: UIControl.State.normal)
                
        navigationItem.rightBarButtonItem?.isEnabled = selectedItems.count == 0 ? false : true
        
        navigationController?.navigationBar.tintColor = AppColor.label.color
    }
    
    private func addChildVC() {
        let dataSource: PhotoSelectionDataSourceProtocol = isFavouritePictures ? FavoritePhotosSelectionDataSource(pageSize: 100) : AllPhotosSelectionDataSource(pageSize: 100)

        let childController = PhotoSelectionController(title: "",
                                                       selectingLimit: selectingLimit,
                                                       delegate: self,
                                                       dataSource: dataSource)
        
        // or change with TextConstants.snackbarMessageCreateStoryLimit
        let message = String(format: TextConstants.snackbarMessageCreateStoryLimit, selectingLimit)
        containerView?.snackBarLabel.text = message
        selectionDelegate = childController
        addChild(childController)
        containerView?.contentView.addSubview(childController.view)
        childController.view.frame = containerView?.contentView.bounds ?? .zero
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        childController.didMove(toParent: self)
    }
    
    private func updateScreen() {
        var navigationTitle = navTitle
        
        let selectedItemsCount = selectedItems.count
        if selectedItemsCount > 0 {
            navigationTitle = String(format: TextConstants.createStoryPhotosSelected, selectedItemsCount)
        }
        
        setTitle(withString: navigationTitle)
        
        if selectionState == .ended {
            let message = String(format: TextConstants.snackbarMessageCreateStoryLimit, selectingLimit)
            SnackbarManager.shared.show(type: .critical, message: message, action: .ok)
        }
        selectionDelegate?.selectionStateDidChange(selectionState)
    }
    
    @objc private func openStorySetup() {
        let story = PhotoStory(name: "")
        story.storyPhotos = selectedItems.map { Item(remote: $0) }
        let router = RouterVC()
        let controller = router.audioSelection(forStory: story)
        controller.fromPhotoSelection = true
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

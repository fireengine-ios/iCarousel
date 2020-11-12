//
//  PrivateShareSharedFilesViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 10.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareSharedFilesViewController: BaseViewController, SegmentedChildController, NibInit {
    
    static func with(shareType: PrivateShareType) -> PrivateShareSharedFilesViewController {
        let controller = PrivateShareSharedFilesViewController.initFromNib()
        let title: String
        switch shareType {
            case .byMe: title = TextConstants.privateShareSharedByMeTab
            case .withMe: title = TextConstants.privateShareSharedWithMeTab
        }
        controller.title = title
        controller.shareType = shareType
        return controller
    }

    
    @IBOutlet weak var topBarContainer: UIView!
    @IBOutlet private weak var collectionView: QuickSelectCollectionView!
    
    private lazy var gridListBar: GridListTopBar = {
        let bar = GridListTopBar.initFromXib()
        bar.delegate = self
        return bar
    }()
    
    private var shareType: PrivateShareType = .byMe
    
    private lazy var collectionManager: PrivateShareSharedFilesCollectionManager = {
        let apiService = PrivateShareApiServiceImpl()
        let sharedItemsManager = PrivateShareFileInfoManager.with(type: shareType, privateShareAPIService: apiService)
        let manager = PrivateShareSharedFilesCollectionManager.with(collection: collectionView, fileInfoManager: sharedItemsManager)
        manager.delegate = self
        return manager
    }()
    
    private lazy var navBarManager = PhotoVideoNavBarManager(delegate: self)
    
    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(title ?? "")
        collectionManager.setup()
        setupBars()
    }
    
    //MARK: - Private
    
    private func setupBars() {
        needToShowTabBar = true
        navigationBarWithGradientStyle(isHidden: false, hideLogo: true)
        setupTopBar()
    }
    
    private func setupTopBar() {
        
        gridListBar.view.translatesAutoresizingMaskIntoConstraints = false
        topBarContainer.addSubview(gridListBar.view)
        gridListBar.view.pinToSuperviewEdges()
        
        let sortingTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
        let config = GridListTopBarConfig(defaultGridListViewtype: .Grid,
                                          availableSortTypes: sortingTypes,
                                          defaultSortType: .TimeNewOld,
                                          availableFilter: false,
                                          showGridListButton: true)
        gridListBar.setupWithConfig(config: config)
    }
}


//MARK: - GridListTopBarDelegate
extension PrivateShareSharedFilesViewController: GridListTopBarDelegate {
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType) {
        //disabled
    }
    
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType) {
        collectionManager.change(sortingRule: rule.sortedRulesConveted)
    }
    
    func representationChanged(viewType: MoreActionsConfig.ViewType) {
        collectionManager.change(viewType: viewType)
    }
}

//MARK: - PrivateShareSharedFilesCollectionManagerDelegate
extension PrivateShareSharedFilesViewController: PrivateShareSharedFilesCollectionManagerDelegate {
    func didStartSelection(selected: Int) {
        setupNavigationBar(editingMode: true)
    }
    
    func didChangeSelection(selected: Int) {
        update(selectedItemsCount: selected)
//        updateBarsForSelectedObjects()
    }
    
    
    //MARK: Helpers
    
    private func update(selectedItemsCount: Int) {
        DispatchQueue.main.async {
            self.setTitle("\(selectedItemsCount) \(TextConstants.accessibilitySelected)")
        }
    }
    
    private func setupNavigationBar(editingMode: Bool) {
        /// don't let vc to change navBar if vc is not visible at this moment
        guard viewIfLoaded?.window != nil else {
            return
        }
        
        /// be sure to configure navbar items after setup navigation bar
        if editingMode {
            navBarManager.setSelectionMode()
        } else {
            navBarManager.setDefaultMode()
        }
    }
}


//MARK: - PhotoVideoNavBarManagerDelegate
extension PrivateShareSharedFilesViewController: PhotoVideoNavBarManagerDelegate {
    func onCancelSelectionButton() {
        collectionManager.cancelSelection()
    }
    
    func onThreeDotsButton() {
        //TODO:
    }
    
    func onSearchButton() {
        //TODO:
    }
}

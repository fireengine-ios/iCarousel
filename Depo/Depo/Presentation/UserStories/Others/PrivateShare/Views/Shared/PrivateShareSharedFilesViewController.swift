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
            case .innerFolder(_, let name): title = name
        }
        controller.title = title
        controller.shareType = shareType
        return controller
    }

    
    @IBOutlet weak var collectionViewBarContainer: UIView!
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
    
    private lazy var navBarManager = SegmentedChildNavBarManager(delegate: self)
    private lazy var bottomBarManager = PrivateShareSharedFilesBottomBarManager(delegate: self)
    
    private let router = RouterVC()
    
    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionManager.setup()
        setupBars()
        showSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomBarManager.updateLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupNavigationBar(editingMode: false)
        
        let selectedItems = collectionManager.selectedItems()
        if !selectedItems.isEmpty {
            setupNavigationBar(editingMode: true)
            show(selectedItemsCount: selectedItems.count)
            bottomBarManager.update(for: selectedItems)
        }
    }
    
    //MARK: - Private
    
    private func setupBars() {
        setDefaultTabBarState()
        navBarManager.setDefaultMode(title: title ?? "")
        navigationBarWithGradientStyle(isHidden: false, hideLogo: true)
        setupCollectionViewBar()
        bottomBarManager.setup()
    }
    
    private func setDefaultTabBarState() {
        switch shareType {
            case .byMe, .withMe:
                needToShowTabBar = true
                
            case .innerFolder(uuid: _, name: _):
                needToShowTabBar = false
        }
    }
    
    private func setupCollectionViewBar() {
        gridListBar.view.translatesAutoresizingMaskIntoConstraints = false
        collectionViewBarContainer.addSubview(gridListBar.view)
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
        //disabled by availableFilter: false
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
        updateBars(isSelecting: true)
    }
    
    func didEndSelection() {
        updateBars(isSelecting: false)
    }
    
    func didChangeSelection(selectedItems: [WrapData]) {
        show(selectedItemsCount: selectedItems.count)
        bottomBarManager.update(for: selectedItems)
    }
    
    func didEndReload() {
        hideSpinner()
    }
    
    //MARK: Helpers
    
    private func show(selectedItemsCount: Int) {
        DispatchQueue.main.async {
            self.setTitle("\(selectedItemsCount) \(TextConstants.accessibilitySelected)")
        }
    }
    
    private func updateBars(isSelecting: Bool) {
        DispatchQueue.main.async {
            self.setupNavigationBar(editingMode: isSelecting)
            if isSelecting {
                self.bottomBarManager.show()
            } else {
                self.bottomBarManager.hide()
            }
        }
    }

    private func setupNavigationBar(editingMode: Bool) {
        DispatchQueue.main.async {
            /// don't let vc to change navBar if vc is not visible at this moment
            guard self.viewIfLoaded?.window != nil else {
                return
            }
            
            /// be sure to configure navbar items after setup navigation bar
            if editingMode {
                self.navigationBarWithGradientStyle()
                self.navBarManager.setSelectionMode()
            } else {
                self.navBarManager.setDefaultMode(title: self.title ?? "")
                self.navigationBarWithGradientStyle(isHidden: false, hideLogo: true)
            }
        }
    }
}


//MARK: - SegmentedChildNavBarManagerDelegate
extension PrivateShareSharedFilesViewController: SegmentedChildNavBarManagerDelegate {
    func onCancelSelectionButton() {
        collectionManager.endSelection()
    }
    
    func onThreeDotsButton() {
        //TODO: another jira task
    }
    
    func onSearchButton() {
        showSearchScreen()
    }
    
    //MARK: Helpers
    private func showSearchScreen() {
        let controller = router.searchView(navigationController: navigationController)
        router.pushViewController(viewController: controller)
    }
}


extension PrivateShareSharedFilesViewController: BaseItemInputPassingProtocol {
    
    func selectModeSelected() {
        collectionManager.startSelection()
    }
    
    func stopModeSelected() {
        collectionManager.endSelection()
    }
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        selectedItemsCallback(collectionManager.selectedItems())
    }
    
    func operationFinished(withType type: ElementTypes, response: Any?) { }
    
    func operationFailed(withType type: ElementTypes) {}
    
    func selectAllModeSelected() {}
    
    func deSelectAll() {}
    
    func printSelected() {}
    
    func changeCover() {}
    
    func openInstaPick() {}
}

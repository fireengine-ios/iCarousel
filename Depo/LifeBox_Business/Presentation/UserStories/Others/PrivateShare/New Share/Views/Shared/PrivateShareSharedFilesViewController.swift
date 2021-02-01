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
            case .myDisk: title = TextConstants.tabBarItemMyDisk
            case .byMe: title = TextConstants.privateShareSharedByMeTab
            case .withMe: title = TextConstants.privateShareSharedWithMeTab
            case .innerFolder(_, let folder): title = folder.name
            case .sharedArea: title = TextConstants.tabBarItemSharedArea
        }
        controller.title = title
        controller.shareType = shareType
        return controller
    }

    
    @IBOutlet weak var collectionViewBarContainer: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let cardsContainer = CardsContainerView()
    private var contentSliderTopY: NSLayoutConstraint?
    private var contentSliderH: NSLayoutConstraint?
    
    private lazy var gridListBar: GridListTopBar = {
        let bar = GridListTopBar.initFromXib()
        bar.delegate = self
        return bar
    }()
    
    private(set) var shareType: PrivateShareType = .byMe
    
    private lazy var collectionManager: PrivateShareSharedFilesCollectionManager = {
        let apiService = PrivateShareApiServiceImpl()
        let sharedItemsManager = PrivateShareFileInfoManager.with(type: shareType, privateShareAPIService: apiService)
        let manager = PrivateShareSharedFilesCollectionManager.with(collection: collectionView, fileInfoManager: sharedItemsManager)
        manager.delegate = self
        return manager
    }()
    
    private lazy var navBarManager = SegmentedChildNavBarManager(delegate: self)
    private lazy var bottomBarManager = PrivateShareSharedFilesBottomBarManager(delegate: self)
    private lazy var threeDotsManager = PrivateShareSharedWithThreeDotsManager(delegate: self)
    private lazy var itemThreeDotsManager = PrivateShareSharedItemThreeDotsManager(delegate: self)
    
    private let router = RouterVC()
    private let analytics = PrivateShareAnalytics()
    
    //MARK: - Override
    
    deinit {
        CardsManager.default.removeViewForNotification(view: cardsContainer)
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionManager.setup()
        setupBars()
        setupCardsContainer()
        setupPlusButton()
        showSpinner()
        ItemOperationManager.default.startUpdateView(view: self)
        trackScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setCardsContainer(isActive: true)
        bottomBarManager.updateLayout()
        collectionManager.reload(type: .onViewAppear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isSelecting = collectionManager.isSelecting
        updateBars(isSelecting: isSelecting)
        if isSelecting {
            let selectedItems = collectionManager.selectedItems()
            show(selectedItemsCount: selectedItems.count)
            bottomBarManager.update(for: selectedItems)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        setCardsContainer(isActive: false)
    }
    
    override func removeFromParentViewController() {
        super.removeFromParentViewController()
        
        if collectionManager.isSelecting {
            stopModeSelected()
        }
    }
 
    //MARK: - Private
    
    private func setupBars() {
        setDefaultTabBarState()
        setupNavBar()
        setupCollectionViewBar()
        bottomBarManager.setup()
    }
    
    private func setupNavBar() {
        setupNavigationBar(editingMode: false)
    }
    
    private func setupPlusButton() {
        floatingButtonsArray = shareType.floatingButtonTypes(rootPermissions: collectionManager.rootPermissions)
    }
    
    private func setDefaultTabBarState() {
        needToShowTabBar = true
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
    
    private func setupCardsContainer() {
        CardsManager.default.addViewForNotification(view: cardsContainer)
        
        cardsContainer.delegate = self
        cardsContainer.isEnable = true
        
        let permittedTypes: [OperationType]
        switch shareType.rootType {
            case .byMe:
                permittedTypes = [.upload, .download]
            case .withMe:
                permittedTypes = [.sharedWithMeUpload, .download]
            case .myDisk:
                permittedTypes = [.upload, .download]
            case .sharedArea:
                permittedTypes = [.upload, .download]
            default:
                permittedTypes = []
        }
        
        cardsContainer.addPermittedPopUpViewTypes(types: permittedTypes)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        collectionView.addSubview(cardsContainer)
        
        cardsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        var constraintsArray = [NSLayoutConstraint]()
        contentSliderTopY = NSLayoutConstraint(item: cardsContainer, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 0)
        constraintsArray.append(contentSliderTopY!)
        constraintsArray.append(NSLayoutConstraint(item: cardsContainer, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: cardsContainer, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        contentSliderH = NSLayoutConstraint(item: cardsContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        constraintsArray.append(contentSliderH!)
        
        NSLayoutConstraint.activate(constraintsArray)
    }
    
    private func setCardsContainer(isActive: Bool) {
        cardsContainer.isActive = isActive
        if isActive {
            CardsManager.default.updateAllProgressesInCardsForView(view: cardsContainer)
        }
    }
    
    private func trackScreen() {
        switch shareType {
        case .byMe:
            analytics.trackScreen(.sharedByMe)
        case .withMe:
            analytics.trackScreen(.sharedWithMe)
        default:
            break
        }
    }
}


//MARK: - GridListTopBarDelegate
extension PrivateShareSharedFilesViewController: GridListTopBarDelegate {
    
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
        
        if selectedItems.isEmpty {
            bottomBarManager.hide()
        } else {
            bottomBarManager.show()
        }
    }
    
    func didEndReload() {
        hideSpinner()
        setupPlusButton()
    }
    
    func showActions(for item: WrapData, sender: Any) {
        itemThreeDotsManager.showActions(for: shareType, item: item, sender: sender)
    }
    
    func didSelectAction(type: ActionType, on item: Item, sender: Any?) {
        itemThreeDotsManager.handleAction(type: type, item: item, sender: sender)
    }
    
    func needToHideSpinner() {
        hideSpinner()
    }
    
    func needToShowSpinner() {
        showSpinner()
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
            
            if self.shareType.isSelectionAllowed {
                self.navBarManager.threeDotsButton.isEnabled = !isSelecting
            }
            self.needToShowTabBar = !isSelecting
            self.showTabBarIfNeeded()
            if isSelecting {
                let selectedItems = self.collectionManager.selectedItems()
                self.show(selectedItemsCount: selectedItems.count)
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
            let isSelectionAllowed = self.shareType.isSelectionAllowed
            
            if editingMode, isSelectionAllowed {
                self.navigationBarWithGradientStyle()
                self.navBarManager.setSelectionMode()
            } else {
                let isTabBarItem = (self.parent as? SegmentedController)?.isTabBarItem == true
                
                let title = isTabBarItem ? "" : self.title ?? ""
                if !isSelectionAllowed {
                    self.navBarManager.setDefaultModeWithoutThreeDot(title: title)
                } else {
                    self.navBarManager.setDefaultMode(title: title)
                }
                
                if isTabBarItem {
                    self.homePageNavigationBarStyle()
                } else {
                    self.navigationBarWithGradientStyle(isHidden: false, hideLogo: true)
                }
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
        if collectionManager.isSelecting {
            threeDotsManager.showActions(for: shareType, selectedItems: collectionManager.selectedItems(), sender: self)
        } else {
            threeDotsManager.showActions(for: shareType, sender: self)
        }
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
    
    func getSelectedItems(selectedItemsCallback: @escaping ValueHandler<[BaseDataSourceItem]>) {
        selectedItemsCallback(collectionManager.selectedItems())
    }
    
    func operationFinished(withType type: ElementTypes, response: Any?) {
        switch shareType.rootType {
            case .withMe:
                if type.isContained(in: [.rename, .move, .share]) {
                    collectionManager.reload(type: .onOperationFinished)
                }
                
            case .byMe:
                if type.isContained(in: [.rename, .move, .share, .addToFavorites, .removeFromFavorites]) {
                    collectionManager.reload(type: .onOperationFinished)
                }
                
            case .myDisk:
                if type.isContained(in: [.rename, .move, .share, .addToFavorites, .removeFromFavorites]) {
                    collectionManager.reload(type: .onOperationFinished)
                }
                
            case .sharedArea:
                if type.isContained(in: [.rename, .move, .share, .addToFavorites, .removeFromFavorites]) {
                    collectionManager.reload(type: .onOperationFinished)
                }
                
            default:
                assertionFailure()
        }
    }
    
    func operationFailed(withType type: ElementTypes) {}
    
    func selectAllModeSelected() {}
    
    func deSelectAll() {}
    
    func printSelected() {}
    
    func changeCover() {}
    
    func openInstaPick() {}
}


extension PrivateShareSharedFilesViewController: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        return self === object
    }
    
    func syncFinished() {
        collectionManager.reload(type: .onOperationFinished)
    }
    
    func didMoveToTrashItems(_ items: [Item]) {
        collectionManager.delete(uuids: items.compactMap { $0.uuid })
    }
    
    func didMoveToTrashSharedItems(_ items: [Item]) {
        collectionManager.delete(uuids: items.compactMap { $0.uuid })
    }
    
    func didEndShareItem(uuid: String) {
        if shareType.rootType == .byMe {
            collectionManager.delete(uuids: [uuid])
        }
    }
    
    func didLeaveShareItem(uuid: String) {
        if shareType.rootType == .withMe {
            collectionManager.delete(uuids: [uuid])
        }
    }
}


extension PrivateShareSharedFilesViewController: CardsContainerViewDelegate {
    func onUpdateViewForPopUpH(h: CGFloat) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            if let yConstr = self.contentSliderTopY {
                yConstr.constant = -h
            }
            if let hConstr = self.contentSliderH {
                hConstr.constant = h
            }

            self.collectionView.superview?.layoutIfNeeded()
            self.collectionView.contentInset = UIEdgeInsets(top: h, left: 0, bottom: 25, right: 0)
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }

            if self.collectionView.contentOffset.y < 1 {
                self.collectionView.contentOffset = CGPoint(x: 0.0, y: -self.collectionView.contentInset.top)
            }
        })
    }
}

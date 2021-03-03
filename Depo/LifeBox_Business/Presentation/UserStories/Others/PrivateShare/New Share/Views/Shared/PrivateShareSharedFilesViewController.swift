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
        controller.needToShowTabBar = true
        return controller
    }

    
    @IBOutlet weak var collectionViewBarContainer: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let cardsContainer = CardsContainerView()
    private var contentSliderTopY: NSLayoutConstraint?
    private var contentSliderH: NSLayoutConstraint?
    
    private lazy var cameraService = CameraService()
    private lazy var galleryFileUploadService = GalleryFileUploadService()
    private lazy var externalFileUploadService = ExternalFileUploadService()
    
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
    private lazy var plusButtonActionsManager = PrivateShareSharedPlusButtonActtionManager(delegate: self)
    
    private let router = RouterVC()
    private let analytics = PrivateShareAnalytics()
    
    //MARK: - Override
    
    override var keyboardHeight: CGFloat {
        willSet {
            let offset = max(0, newValue + 25)
            collectionView?.contentInset.bottom = offset
        }
    }
    
    deinit {
        CardsManager.default.removeViewForNotification(view: cardsContainer)
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionManager.setup()
        setupPlusButton()//should be called before bars, otherwise plus button  would be innactive for ios14+
        setupBars()
        setupCardsContainer()
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
            self.defaultNavBarStyle()
            /// be sure to configure navbar items after setup navigation bar
            let isSelectionAllowed = self.shareType.isSelectionAllowed
            
            if editingMode, isSelectionAllowed {
                self.navBarManager.setSelectionMode()
            } else {
                
                let isTabBarItem = (self.parent as? SegmentedController)?.isTabBarItem == true
                
                let title = isTabBarItem ? "" : self.title ?? ""

                if case .innerFolder(_, _) = self.shareType {
                    self.navBarManager.setNestedMode(title: title)
                } else {
                    self.navBarManager.setDefaultMode(title: title)
                }
            }
        }
    }
}


//MARK: - SegmentedChildNavBarManagerDelegate
extension PrivateShareSharedFilesViewController: SegmentedChildNavBarManagerDelegate {
    
    func plussButtonCreated(button: UIBarButtonItem) {
        guard #available(iOS 14, *),
              let realButton = button.customView as? UIButton
        else {
            return
        }
        
        realButton.showsMenuAsPrimaryAction = true
        realButton.menu = plusButtonActionsManager.generateMenu(for: floatingButtonsArray, actionsDelegate: self)
        
    }
    
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
    
    func onPlusButton() {
        plusButtonActionsManager.showActions(for: floatingButtonsArray, sender:  navigationItem.rightBarButtonItem, actionsDelegate: self)
    }
    
    func onSettingsButton() {
        var controller: UIViewController?
        
        if Device.isIpad {
            controller = router.settingsIpad(settingsController: router.settings)
        } else {
            controller = router.settings
        }
        
        router.pushViewController(viewController: controller!)
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
    
    func renamingSelected(item: Item) {
        collectionManager.startRenaming(item: item)
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
    
    func operationCancelled(withType type: ElementTypes) {
        if type.isContained(in: [.moveToTrash, .moveToTrashShared]) {
            collectionManager.reload(type: .onViewAppear)
        }
    }
    
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
    
    func didRenameItem(_ item: BaseDataSourceItem) {
        collectionManager.reload(type: .onOperationFinished)
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

//MARK: - UIImagePickerControllerDelegate

extension PrivateShareSharedFilesViewController: GalleryFileUploadServiceDelegate {
    func uploaded(items: [WrapData]) {
        //
    }
    
    func failed(error: ErrorResponse?) {
        guard let error = error else {
            return
        }
        
        guard !error.isOutOfSpaceError else {
            //showing special popup for this error
            return
        }
        
        DispatchQueue.main.async {
            let vc = PopUpController.with(title: TextConstants.errorAlert,
                                          message: error.description,
                                          image: .error,
                                          buttonTitle: TextConstants.ok)
            self.router.presentViewController(controller: vc, animated: true, completion: nil)//.present(vc, animated: true, completion: nil)
        }
    }
}

extension PrivateShareSharedFilesViewController: PrivateShareSharedPlusButtonActtionDelegate {
    
    func subPlusActionPressed(type: TabBarViewController.Action) {
        handlePlusButtonAction(type)
    }

    private func handlePlusButtonAction(_ action: TabBarViewController.Action) {
        
        switch action {
        case .createFolder(type: _):
            let controller: UIViewController
            if let sharedFolder = router.sharedFolderItem {
                let isSharedByWithMe = sharedFolder.type.isContained(in: [.byMe, .withMe])
                let parameters = CreateFolderParameters(accountUuid: sharedFolder.accountUuid, rootFolderUuid: sharedFolder.uuid, isShared: isSharedByWithMe)
                controller = router.createNewFolder(parameters: parameters)
            } else {
                assertionFailure()
                return
            }
            
            let nController = NavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
            
        case .upload(type: let uploadType):
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .uploadFromPlus))
            galleryFileUploadService.upload(type:uploadType, rootViewController: self, delegate: self)
            
        case .uploadFiles(type: let uploadType):
            externalFileUploadService.showViewController(type: uploadType, router: router, externalFileType: .any)
            
        case .uploadFromApp:
            let parentFolder = router.getParentUUID()
            
             let controller = router.uploadFromLifeBox(folderUUID: parentFolder)
            
            let navigationController = NavigationController(rootViewController: controller)
            navigationController.navigationBar.isHidden = false
            router.presentViewController(controller: navigationController)
        }
    }
}

//
//  PrivateShareSharedFilesViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 10.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareSharedFilesViewControllerOffsetChangeDelegate: class {
    func offsettChanged(newOffSet: CGFloat)
}

final class PrivateShareSharedFilesViewController: BaseViewController, SegmentedChildTopBarSupportedControllerProtocol, NibInit {
    
    static func with(shareType: PrivateShareType) -> PrivateShareSharedFilesViewController {
        let controller = PrivateShareSharedFilesViewController.initFromNib()
        controller.title = shareType.title
        controller.shareType = shareType
        controller.needToShowTabBar = true
        return controller
    }

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private lazy var cameraService = CameraService()
    private lazy var galleryFileUploadService = GalleryFileUploadService()
    private lazy var externalFileUploadService = ExternalFileUploadService()
    
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
    
    lazy private var topBarSortingBar: TopBarSortingView = {
        let sortingBar = TopBarSortingView.initFromNib()
        sortingBar.delegate = self
        return sortingBar
    }()
    
    private var collectionTopYInset: CGFloat = 0
    
    weak var offsetChangedDelegate: PrivateShareSharedFilesViewControllerOffsetChangeDelegate?
    
    override var isEditing: Bool {
        willSet {
            if case .innerFolder(_, _) = self.shareType {
                
            } else {
                changeNavbarLargeTitle(!newValue)
            }
            if shareType.isSearchAllowed {
                setNavSearchConntroller(newValue ? nil : searchController)
            }
        }
    }
    
    lazy private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = TextConstants.topBarSearchSubViewDescriptionTitle
        searchController.obscuresBackgroundDuringPresentation = true
        //also delegate here
        return searchController
    }()
    
    //MARK: - Override
    
    override var keyboardHeight: CGFloat {
        willSet {
            let offset = max(0, newValue + 25)
            collectionView?.contentInset.bottom = offset
        }
    }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionManager.setup()
        setupPlusButton()
        setupBars()
        showSpinner()
        ItemOperationManager.default.startUpdateView(view: self)
        trackScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        bottomBarManager.updateLayout()
        collectionManager.reload(type: .onViewAppear)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isSelecting = collectionManager.isSelecting
        
        if isSelecting {
            let selectedItems = collectionManager.selectedItems()
            show(selectedItemsCount: selectedItems.count)
            bottomBarManager.update(for: selectedItems)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        setNavSearchConntroller(nil)
    }
    
    override func removeFromParentViewController() {
        super.removeFromParentViewController()
        
        if collectionManager.isSelecting {
            stopModeSelected()
        }
    }
 
    //MARK: - Private
    
    private func setupBars() {
        if case .innerFolder(_, _) = self.shareType {
            navBarManager.setupLargetitle(isLarge: false)
        } else {
            navBarManager.setupLargetitle(isLarge: true)
        }
        setDefaultTabBarState()
        setupCollectionViewBars()
        bottomBarManager.setup()
    }
    
    private func setupNavBar() {
//        setNavSearchConntroller(nil)
        setupNavigationBar(editingMode: collectionManager.isSelecting)
    }
    
    private func setupPlusButton() {
        floatingButtonsArray = shareType.floatingButtonTypes(rootPermissions: collectionManager.rootPermissions)
        guard #available(iOS 14, *) else {
            return
        }
        setupPlusButtonMenu()
    }
    
    @available(iOS 14.0, *)
    private func setupPlusButtonMenu() {
        guard
            let realButton = navBarManager.plusButton.customView as? UIButton
        else {
            return
        }
        realButton.showsMenuAsPrimaryAction = true
        realButton.menu = nil
        realButton.menu = plusButtonActionsManager.generateMenu(for: floatingButtonsArray, actionsDelegate: self)
        realButton.addTarget(self, action: #selector(onMenuTriggered), for: .menuActionTriggered)
    }

    @objc private func onMenuTriggered() {
        if floatingButtonsArray.isEmpty {
            SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.noAccessSnackBarTitle)
        }
        
        let lightFeedback = UIImpactFeedbackGenerator(style: .light)
        lightFeedback.impactOccurred()
    }
    
    private func setDefaultTabBarState() {
        needToShowTabBar = true
    }
    
    private func setupCollectionViewBars() {
        setupSorttingBar()

        collectionView.contentInset = UIEdgeInsets(top: collectionTopYInset, left: 0, bottom: 25, right: 0)
    }
    
    private func setupSorttingBar() {
        let sortingTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
           
        topBarSortingBar.setupSortingMenu(sortTypes: sortingTypes, defaultSortType: .TimeNewOld)
        
        collectionView.addSubview(topBarSortingBar)
        
        collectionTopYInset += topBarSortingBar.frame.height
        
        topBarSortingBar.translatesAutoresizingMaskIntoConstraints = false
        
        topBarSortingBar.topAnchor.constraint(equalTo: self.collectionView.topAnchor, constant: -collectionTopYInset).activate()
        topBarSortingBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).activate()
        topBarSortingBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).activate()
    }
    
    private func handleOffsetChange(offsetY: CGFloat) {
        offsetChangedDelegate?.offsettChanged(newOffSet: offsetY + collectionTopYInset)
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
        isEditing = true
        updateBars(isSelecting: true)
    }
    
    func didEndSelection() {
        isEditing = false
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
        if shareType.isSearchAllowed {
            setNavSearchConntroller(searchController)
        }
        setupPlusButton()
        handleOffsetChange(offsetY: collectionView.contentOffset.y)
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
            self.setTitle("\(selectedItemsCount) \(TextConstants.accessibilitySelected)", isSelectionMode: true)
        }
    }
    
    private func updateBars(isSelecting: Bool) {
        DispatchQueue.toMain {
            self.setupNavigationBar(editingMode: isSelecting)
            
            self.needToShowTabBar = !isSelecting
            self.showTabBarIfNeeded()
            if isSelecting {
                let selectedItems = self.collectionManager.selectedItems()
                self.show(selectedItemsCount: selectedItems.count)
                self.bottomBarManager.show()
                self.bottomBarManager.update(for: selectedItems)
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

            self.setNavigationBarStyle(.white)
            
            /// be sure to configure navbar items after setup navigation bar
            let isSelectionAllowed = self.shareType.isSelectionAllowed
            
            if editingMode, isSelectionAllowed {
                self.navBarManager.setSelectionMode()
            } else {
                if case .innerFolder(_, _) = self.shareType {
                    self.navBarManager.setNestedMode(title: self.shareType.title)
                } else {
                    var newTitle = self.shareType.title
                    if let segmentedParent = self.parent as? TopBarSupportedSegmentedController {
                        newTitle = segmentedParent.rootTitle
                    }
                    self.navBarManager.setupLargetitle(isLarge: true)///????
                    self.navBarManager.setRootMode(title: newTitle)
                }
            }
            self.handleOffsetChange(offsetY: self.collectionView.contentOffset.y)
        }
    }
    
    func collectionOffsetChanged(offsetY: CGFloat) {
        handleOffsetChange(offsetY: offsetY)
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
    
    func onPlusButton() {
        guard !floatingButtonsArray.isEmpty else {
            SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.noAccessSnackBarTitle)
            return
        }
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
    func selectModeSelected(with item: WrapData?) {
        isEditing = true
        collectionManager.startSelection(with: item)
    }
    
    func stopModeSelected() {
        isEditing = false
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
    
    func deSelectAll() {
        isEditing = false
        handleOffsetChange(offsetY: collectionView.contentOffset.y)
    }
    
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

extension PrivateShareSharedFilesViewController: TopBarSortingViewDelegate {
    func sortingTypeChanged(sortType: MoreActionsConfig.SortRullesType) {
        collectionManager.change(sortingRule: sortType.sortedRulesConveted)
    }
}

//
//  PrivateShareSharedFilesViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 10.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareSharedFilesViewController: BaseViewController, SegmentedChildTopBarSupportedControllerProtocol, NibInit {
    
    static func with(shareType: PrivateShareType) -> PrivateShareSharedFilesViewController {
        let controller = PrivateShareSharedFilesViewController.initFromNib()
        controller.title = shareType.title
        controller.shareType = shareType
        controller.needToShowTabBar = shareType.isTabBarNeeded
        return controller
    }

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private lazy var cameraService = CameraService()
    private lazy var galleryFileUploadService = GalleryFileUploadService()
    private lazy var externalFileUploadService = ExternalFileUploadService()
    
    private(set) var shareType: PrivateShareType = .byMe
    
    private lazy var collectionManager: PrivateShareSharedFilesCollectionManager = {
        let manager = PrivateShareSharedFilesCollectionManager.with(collection: collectionView, fileInfoManager: fileInfoManager)
        manager.delegate = self
        return manager
    }()
    
    private lazy var navBarManager = SegmentedChildNavBarManager(delegate: self)
    private lazy var bottomBarManager = PrivateShareSharedFilesBottomBarManager(delegate: self)
    private lazy var threeDotsManager = PrivateShareSharedWithThreeDotsManager(delegate: self)
    private lazy var itemThreeDotsManager = PrivateShareSharedItemThreeDotsManager(delegate: self)
    private lazy var plusButtonActionsManager = PrivateShareSharedPlusButtonActtionManager(delegate: self)
    private lazy var fileInfoManager: PrivateShareFileInfoManager = {
        let apiService = PrivateShareApiServiceImpl()
        return PrivateShareFileInfoManager.with(type: shareType, privateShareAPIService: apiService)
    }()
    
    private let router = RouterVC()
    private let analytics = PrivateShareAnalytics()
    
    lazy private var topBarSortingBar: TopBarSortingView = {
        let sortingBar = TopBarSortingView.initFromNib()
        sortingBar.delegate = self
        return sortingBar
    }()
    
    var collectionTopYInset: CGFloat = 0
 
    lazy private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = TextConstants.topBarSearchSubViewDescriptionTitle
        searchController.obscuresBackgroundDuringPresentation = true
        //TODO: also setup delegate here
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
        setupBars()
        setupNavigationBar(editingMode: collectionManager.isSelecting)
        setupPlusButton()
        
        showSpinner()
        ItemOperationManager.default.startUpdateView(view: self)
        trackScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationBar(editingMode: collectionManager.isSelecting)
        
        bottomBarManager.updateLayout()
        collectionManager.reload(type: .onViewAppear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isSelecting = collectionManager.isSelecting
        
        if isSelecting {
            let selectedItems = collectionManager.selectedItems()
            show(selectedItemsCount: selectedItems.count)
            bottomBarManager.update(for: selectedItems, shareType: shareType)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navBarManager.setExtendedLayoutNavBar(extendedLayoutIncludesOpaqueBars: false)
    }
    
    override func removeFromParentViewController() {
        super.removeFromParentViewController()
        
        if collectionManager.isSelecting {
            stopModeSelected()
        }
    }
 
    //MARK: - Private
    
    private func setupBars() {
        //in theory should provide smoother animation if initial setup wasn on viewDidLoad
        switch shareType {
        case .innerFolder(_, _), .trashBin:
            navBarManager.setupLargetitle(isLarge: false)
        default:
            navBarManager.setupLargetitle(isLarge: true)
        }
        setDefaultTabBarState()
        setupCollectionViewBars()
        bottomBarManager.setup()
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
            shareType != .trashBin,
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
        guard ReachabilityService.shared.isReachable else {
            UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
            return
        }
        
        if floatingButtonsArray.isEmpty {
            SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.noAccessSnackBarTitle)
        }
        
        let lightFeedback = UIImpactFeedbackGenerator(style: .light)
        lightFeedback.impactOccurred()
    }
    
    private func setDefaultTabBarState() {
        needToShowTabBar = shareType.isTabBarNeeded
    }
    
    private func setupCollectionViewBars() {
        setupSortingBar()
        collectionView.contentInset = UIEdgeInsets(top: collectionTopYInset, left: 0, bottom: 25, right: 0)
    }
    
    private func setupSortingBar() {
        let sortingTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .lastModifiedTimeNewOld, .lastModifiedTimeOldNew, .Largest, .Smallest]
           
        topBarSortingBar.setupSortingMenu(sortTypes: sortingTypes, defaultSortType: .lastModifiedTimeNewOld)
        
        collectionView.addSubview(topBarSortingBar)
        
        
        
        topBarSortingBar.translatesAutoresizingMaskIntoConstraints = false
        
        topBarSortingBar.topAnchor.constraint(equalTo: self.collectionView.topAnchor, constant: collectionTopYInset - topBarSortingBar.frame.height).activate()
        topBarSortingBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).activate()
        topBarSortingBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).activate()
        
        collectionTopYInset += topBarSortingBar.frame.height
    }
    
    
    //shall be called frorm segment
    func setupSegmentedControlView(segmentedView: UIView) {
        
        let newOffset = collectionTopYInset + segmentedView.frame.height

        segmentedView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.addSubview(segmentedView)
        
        let collectionTopConstraint = segmentedView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: -newOffset)
        collectionTopConstraint.priority = .defaultLow
        
        let minimalNavBarHeight: CGFloat = 46
        
        let superTopConstraintValue: CGFloat = segmentedView.frame.height + minimalNavBarHeight
        
        let superTopConstraint = NSLayoutConstraint(item: segmentedView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .top, multiplier: 1, constant: superTopConstraintValue)
        superTopConstraint.priority = .defaultHigh
        
        let leading = segmentedView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        let trailing = segmentedView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        
        NSLayoutConstraint.activate([collectionTopConstraint, leading, trailing, superTopConstraint])
        
        collectionView.contentInset = UIEdgeInsets(top: newOffset, left: 0, bottom: 25, right: 0)
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
        DispatchQueue.main.async {
            self.updateBars(isSelecting: true)
            switch self.shareType {
            case .innerFolder, .trashBin:
                break
            default:
                self.changeNavbarLargeTitle(false, style: .white)
                if self.shareType.isSearchAllowed {//from requrements it seems that search is possible on root pages only
                    self.setNavSearchConntroller(nil)
                }
            }
        }
        
    }
    
    func didEndSelection() {
        DispatchQueue.main.async {
            self.updateBars(isSelecting: false)
            switch self.shareType {
            case .innerFolder, .trashBin:
                break
            default:
                self.changeNavbarLargeTitle(true, style: .white)
                if self.shareType.isSearchAllowed {//from requrements it seems that search is possible on root pages only
                    self.setNavSearchConntroller(self.searchController)
                }
            }
        }
    }
    
    func didChangeSelection(selectedItems: [WrapData]) {
        show(selectedItemsCount: selectedItems.count)
        bottomBarManager.update(for: selectedItems, shareType: shareType)
        
        if selectedItems.isEmpty {
            bottomBarManager.hide()
        } else {
            bottomBarManager.show()
        }
    }
    
    func didEndReload() {
        hideSpinner()
        
        if self.shareType.isSearchAllowed {
            self.setNavSearchConntroller(self.searchController)
        }
        
        self.setupPlusButton()
        self.view.layoutSubviews()
        
        if !ReachabilityService.shared.isReachable {
            UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
        }
    }
    
    func showActions(for item: WrapData, sender: Any) {
        itemThreeDotsManager.showActions(for: shareType, item: item, sender: sender)
    }
    
    func didSelectAction(type: ElementTypes, on item: Item, sender: Any?) {
        itemThreeDotsManager.handleAction(type: type, item: item, sender: sender)
    }
    
    func needToHideSpinner() {
        hideSpinner()
    }
    
    func needToShowSpinner() {
        showSpinner()
    }

    func onEmptyViewUpdate(isHidden: Bool) {
        if shareType == .trashBin {
            navBarManager.setTrashBinMode(title: self.shareType.title, emptyDataList: !isHidden)
            navBarManager.setupLargetitle(isLarge: false)
            topBarSortingBar.isHidden = !isHidden
        }
    }
    
    //MARK: Helpers
    
    private func show(selectedItemsCount: Int) {
        DispatchQueue.main.async {
            self.setTitle("\(selectedItemsCount) \(TextConstants.accessibilitySelected)", isSelectionMode: true, style: .white)
        }
    }
    
    private func updateBars(isSelecting: Bool) {
        
        self.setupNavigationBar(editingMode: isSelecting)
        
        let tabBarNeeded = self.shareType != .trashBin
        
        if tabBarNeeded {
            self.needToShowTabBar = !isSelecting
            self.showTabBarIfNeeded()
        }
        
        if isSelecting {
            let selectedItems = self.collectionManager.selectedItems()
            self.show(selectedItemsCount: selectedItems.count)
            self.bottomBarManager.show()
            self.bottomBarManager.update(for: selectedItems, shareType: self.shareType)
        } else {
            self.bottomBarManager.hide()
        }
        
    }

    private func setupNavigationBar(editingMode: Bool) {

        self.setNavigationBarStyle(.white)
        
        /// be sure to configure navbar items after setup navigation bar
        let isSelectionAllowed = self.shareType.isSelectionAllowed
        
        if editingMode, isSelectionAllowed {
            if self.shareType == .trashBin || self.shareType.rootType == .trashBin {
                self.navBarManager.setSelectionModeForTrashBin()
            } else {
                self.navBarManager.setSelectionMode()
            }
        } else {
            switch self.shareType {
            case .trashBin:
                //                    self.setNavBarStyle(.white)
                self.navBarManager.setTrashBinMode(title: self.shareType.title)
                
            case .innerFolder(let rootType, let folderItem):
                if rootType != .trashBin {
                    self.navBarManager.setNestedMode(title: self.shareType.title)
                } else {
                    self.navBarManager.setTrashBinMode(title: folderItem.name, innerFolder: true)
                }
            default:
                self.navBarManager.setExtendedLayoutNavBar(extendedLayoutIncludesOpaqueBars: true)
                var newTitle = self.shareType.title
                if let segmentedParent = self.parent as? TopBarSupportedSegmentedController {
                    newTitle = segmentedParent.rootTitle
                }
                self.navBarManager.setupLargetitle(isLarge: true)
                self.navBarManager.setRootMode(title: newTitle)
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
    
    func onPlusButton() {
        guard ReachabilityService.shared.isReachable else {
            UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
            return
        }
        
        guard !floatingButtonsArray.isEmpty else {
            SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.noAccessSnackBarTitle)
            return
        }
        plusButtonActionsManager.showActions(for: floatingButtonsArray, sender:  navigationItem.rightBarButtonItem, actionsDelegate: self)
    }
    
    func onSettingsButton() {
        let controller = router.settings
        router.pushViewController(viewController: controller!)
    }

    func onTrashBinButton() {
        let cancelHandler: PopUpButtonHandler = { vc in
            vc.close()
        }

        let okHandler: PopUpButtonHandler = { [weak self] vc in
            vc.close { [weak self] in
                self?.deleteAllFromTrashBin()
            }
        }

        let message = TextConstants.trashBinEmptyTrashConfirmDescription
        let controller = PopUpController.with(title: TextConstants.trashBinEmptyTrashConfirmTitle,
                                              message: message,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.trashBinEmptyTrashNoAction,
                                              secondButtonTitle: TextConstants.trashBinEmptyTrashYesAction,
                                              firstAction: cancelHandler,
                                              secondAction: okHandler)

        router.presentViewController(controller: controller)
    }

    func onBackButton() {
        router.popViewController()
    }

    private func deleteAllFromTrashBin() {
        needToShowSpinner()
        fileInfoManager.privateShareAPIService.deleteAllFromTrashBin(handler: { [weak self] response in
            self?.needToHideSpinner()
            switch response {
            case .success():
                self?.collectionManager.reload(type: .onOperationFinished)
                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.trashBinEmptyTrashSucceed)
            case .failed(let error):
                let errorMessage = (error as? ServerMessageError)?.getPrivateShareError() ?? TextConstants.temporaryErrorOccurredTryAgainLater
                UIApplication.showErrorAlert(message: errorMessage)
            }
        })
    }
    
    //MARK: Helpers
    private func showSearchScreen() {
        let controller = router.searchView(navigationController: navigationController)
        router.pushViewController(viewController: controller)
    }
}

extension PrivateShareSharedFilesViewController: BaseItemInputPassingProtocol {
    func selectModeSelected(with item: WrapData?) {
        collectionManager.startSelection(with: item)
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
            case .trashBin:
                if type.isContained(in: [.restore, .deletePermanently]) {
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
        DispatchQueue.main.async {
            switch self.shareType {
            case .innerFolder, .trashBin:
                break
            default:
                self.changeNavbarLargeTitle(true, style: .white)
                if self.shareType.isSearchAllowed {//from requrements it seems that search is possible on root pages only
                    self.setNavSearchConntroller(self.searchController)
                }
            }
        }
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
            self.router.presentViewController(controller: vc, animated: true, completion: nil)
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

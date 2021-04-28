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
    
    @IBOutlet private weak var bottomBarContainerView: UIView! {
        willSet {
            newValue.isHidden = true
            newValue.backgroundColor = .white
        }
    }
    
    private lazy var cameraService = CameraService()
    private var galleryFileUploadService: GalleryFileUploadService? {
        router.tabBarController?.galleryFileUploadService
    }
    private var externalFileUploadService: ExternalFileUploadService? { router.tabBarController?.externalFileUploadService
    }
    
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
 
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = TextConstants.topBarSearchSubViewDescriptionTitle
        searchController.searchBar.tintColor = ColorConstants.Text.labelTitle.color
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.text = nil
        
        return searchController
    }()
    
    private var topBarHeight: CGFloat {
        guard let navigationBarFrame = navigationController?.navigationBar.frame else {
            return 0
        }
        
        if Device.operationSystemVersionLessThen(13) {
            return navigationBarFrame.origin.y + navigationBarFrame.height + searchController.searchBar.frame.height
        } else {
            return navigationBarFrame.origin.y + navigationBarFrame.height
        }
        
    }
    
    
    private var bottomBarHeight: CGFloat {
        bottomBarContainerView.frame.height
    }
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
        collectionManager.updateOnDidLayout(barInsets: UIEdgeInsets(top: topBarHeight, left: 0,
                                                                   bottom: bottomBarHeight, right: 0))
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionManager.viewWillDisappear()
    }
    
    
    //MARK: - Public
    
    //shall be called from segment
    func setupSegmentedControlView(segmentedView: UIView) {
        
        let newOffset = segmentedView.frame.height

        segmentedView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.addSubview(segmentedView)
        
        let collectionTopConstraint = segmentedView.topAnchor.constraint(equalTo: collectionView.topAnchor,
                                                                         constant: -newOffset)
        collectionTopConstraint.priority = .defaultLow
        
        let superTopConstraint = NSLayoutConstraint(item: segmentedView.safeAreaLayoutGuide,
                                                    attribute: .top,
                                                    relatedBy: .greaterThanOrEqual,
                                                    toItem: view.safeAreaLayoutGuide,
                                                    attribute: .top, multiplier: 1, constant: 0)
        superTopConstraint.priority = .defaultHigh
        
        let leading = segmentedView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        let trailing = segmentedView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        
        NSLayoutConstraint.activate([collectionTopConstraint, leading, trailing, superTopConstraint])
        
        collectionView.contentInset = UIEdgeInsets(top: newOffset, left: 0, bottom: 25, right: 0)
    }
 
    //MARK: - Private
    
    private func setupBars() {
        setDefaultTabBarState()
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
                if self.shareType.isSearchAllowed {
                    self.setNavSearchController(nil)
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
                if self.shareType.isSearchAllowed {
                    self.setNavSearchController(self.searchController)
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
            bottomBarManager.show(on: bottomBarContainerView)
        }
    }
    
    func didEndReload(hasItems: Bool) {
        hideSpinner()
        
        if shareType.isSearchAllowed {
            setNavSearchController(self.searchController)
        }
        
        setupPlusButton()
        updateTrashBinNavBarConfig(isEmptyPage: !hasItems)
        
        view.layoutSubviews()
        
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
        updateTrashBinNavBarConfig(isEmptyPage: !isHidden)
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
            self.bottomBarManager.show(on: self.bottomBarContainerView)
            self.bottomBarManager.update(for: selectedItems, shareType: self.shareType)
        } else {
            self.bottomBarManager.hide()
        }
    }
    
    private func updateTrashBinNavBarConfig(isEmptyPage: Bool) {
        if shareType == .trashBin {
            navBarManager.setTrashBinMode(title: shareType.title, emptyDataList: isEmptyPage)
            navBarManager.setupLargeTitle(isLarge: false)
        }
    }

    private func setupNavigationBar(editingMode: Bool) {
        
        setNavigationBarStyle(.white)
        
        /// be sure to configure navbar items after setup navigation bar
        let isSelectionAllowed = shareType.isSelectionAllowed
        
        if editingMode, isSelectionAllowed {
            if shareType.rootType == .trashBin {
                navBarManager.setSelectionModeForTrashBin()
            } else {
                navBarManager.setSelectionMode()
            }
        } else {
            switch shareType {
            case .trashBin:
                navBarManager.setupLargeTitle(isLarge: false)
                navBarManager.setTrashBinMode(title: shareType.title, emptyDataList: fileInfoManager.items.isEmpty)
                
            case .innerFolder(let rootType, let folderItem):
                navBarManager.setupLargeTitle(isLarge: false)
                if rootType != .trashBin {
                    navBarManager.setNestedMode(title: shareType.title)
                } else {
                    navBarManager.setTrashBinMode(title: folderItem.name, innerFolder: true, emptyDataList: fileInfoManager.items.isEmpty)
                }
                
            case .byMe, .withMe, .myDisk, .sharedArea:
                navBarManager.setExtendedLayoutNavBar(extendedLayoutIncludesOpaqueBars: true)
                var newTitle = shareType.title
                if let segmentedParent = parent as? TopBarSupportedSegmentedController {
                    newTitle = segmentedParent.rootTitle
                }
                
                navBarManager.setupLargeTitle(isLarge: true)
                navBarManager.setRootMode(title: newTitle)
                
                if shareType.isSearchAllowed {
                    searchController.searchBar.text = nil
                    searchController.isActive = false
                }
                
            case .search(from: let rootType, _, text: let searchText):
                
                navBarManager.setRootMode(title: rootType.title)
                navBarManager.setupLargeTitle(isLarge: false)
                navBarManager.setExtendedLayoutNavBar(extendedLayoutIncludesOpaqueBars: true)
                
                searchController.searchBar.text = searchText
                searchController.searchBar.showsCancelButton = true
                setNavSearchController(searchController)
                
                if Device.operationSystemVersionLessThen(13) {
                    navigationItem.hidesSearchBarWhenScrolling = false
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
        guard let settings = router.settings else {
            return
        }
        let controller = UINavigationController(rootViewController: settings)
        router.presentViewController(controller: controller, animated: true, completion: nil)
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
}


//MARK: - BaseItemInputPassingProtocol
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
                    self.setNavSearchController(self.searchController)
                }
            }
        }
    }
    
    func printSelected() {}
    
    func changeCover() {}
    
    func openInstaPick() {}
}


//MARK: - ItemOperationManagerViewProtocol
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
    
    func assetsPreparationWillStart() {
        if let tabBarController = router.tabBarController {
            tabBarController.assetsPreparationWillStart()
        }
    }
    
    func assetsPreparationDidEnd() {
        if let tabBarController = router.tabBarController {
            tabBarController.assetsPreparationDidEnd()
        }
    }
}

//MARK: - PrivateShareSharedPlusButtonActtionDelegate

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
            galleryFileUploadService?.upload(type: uploadType, rootViewController: self, delegate: self)
            
        case .uploadFiles(type: let uploadType):
            externalFileUploadService?.showViewController(type: uploadType, router: router, externalFileType: .any)
            
        case .uploadFromApp:
            let parentFolder = router.getParentUUID()
            
             let controller = router.uploadFromLifeBox(folderUUID: parentFolder)
            
            let navigationController = NavigationController(rootViewController: controller)
            navigationController.navigationBar.isHidden = false
            router.presentViewController(controller: navigationController)
        }
    }
}


//MARK: - UISearchBarDelegate
extension PrivateShareSharedFilesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchBarText = searchBar.text else {
            return
        }
        
        switch shareType {
        
        case .search(from: let rootType, let rootPermissions, _):
            
            shareType = .search(from: rootType, rootPermissions: rootPermissions, text: searchBarText)
            showSpinner()
            collectionManager.search(shareType: shareType) { [weak self] in
                DispatchQueue.main.async {
                    self?.setupNavigationBar(editingMode: false)
                    self?.hideSpinner()
                }
                
            }
            
        case .byMe, .myDisk, .innerFolder(type: _, folderItem: _), .sharedArea, .trashBin, .withMe:
            
            if let permissions = collectionManager.rootPermissions {
                let controller = PrivateShareSharedFilesViewController.with(shareType: .search(from: self.shareType, rootPermissions: permissions, text: searchBarText))
                self.router.pushViewController(viewController: controller, animated: false)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        switch self.shareType {
        
        case .innerFolder, .trashBin, .byMe, .withMe:
            break
            
        case .myDisk, .sharedArea:
            
            self.changeNavbarLargeTitle(true, style: .white)
            setExtendedLayoutNavBar(extendedLayoutIncludesOpaqueBars: true)
            
        case .search:

            hideSpinner()
            router.popViewController(animated: false)
            
        }
    }

}

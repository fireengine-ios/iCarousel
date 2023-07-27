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
            case .innerFolder(_, let folder): title = folder.name
        }
        controller.title = title
        controller.shareType = shareType
        return controller
    }

    
    @IBOutlet weak var collectionViewBarContainer: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var headerStackView: UIStackView!
    
    private let cardsContainer = CardsContainerView()
    private var contentSliderTopY: NSLayoutConstraint?
    private var contentSliderH: NSLayoutConstraint?

    private lazy var gridListBar: GridListTopBar = {
        let bar = GridListTopBar.initFromXib()
        bar.delegate = self
        return bar
    }()
    
    private lazy var countView: GridListCountView  = {
        let view = GridListCountView.initFromNib()
        view.delegate = self
        return view
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

        collectionManager.setup(shareType: self.shareType)
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
        //collectionManager.reload(type: .onViewAppear)
        self.collectionManager.filterOfficeReload(documentType: self.collectionManager.lastSelectDocumentType, completion: {})
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
    
    override func removeFromParent() {
        super.removeFromParent()
        
        if collectionManager.isSelecting {
            stopModeSelected()
        }
    }
 
    //MARK: - Private
    
    private func setupBars() {
        setupNavBar()
        setupCollectionViewBar(moreButtonIsHidden: false)
        bottomBarManager.setup()
        setupTabBar(needToShow: true)
    }
    
    private func setupTabBar(needToShow value: Bool) {
        needToShowTabBar = value
    }
    
    private func setupNavBar() {
        setupNavigationBar(editingMode: false)
    }
    
    private func setupPlusButton() {
        floatingButtonsArray = shareType.floatingButtonTypes
    }
    
    private func setupCollectionViewBar(moreButtonIsHidden: Bool) {
        gridListBar.view.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset.bottom = 60
        collectionViewBarContainer.addSubview(gridListBar.view)
        gridListBar.view.pinToSuperviewEdges()
        
        let sortingTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .TimeNewOld, .TimeOldNew, .Largest, .Smallest]
        let config = GridListTopBarConfig(defaultGridListViewtype: .Grid,
                                          availableSortTypes: sortingTypes,
                                          defaultSortType: .TimeNewOld,
                                          availableFilter: false,
                                          showGridListButton: true,
                                          showMoreButton: moreButtonIsHidden)
        gridListBar.setupWithConfig(config: config)
    }
    
    private func setupCardsContainer() {
        CardsManager.default.addViewForNotification(view: cardsContainer)
        
        cardsContainer.delegate = self
        cardsContainer.isEnable = true
        
        let permittedTypes: [OperationType] = shareType.rootType == .byMe ? [.upload, .download] : [.sharedWithMeUpload, .download]
        cardsContainer.addPermittedPopUpViewTypes(types: permittedTypes)

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
    
    private func moreButtonTapped() {
        if collectionManager.isSelecting {
            threeDotsManager.showActions(for: shareType, selectedItems: collectionManager.selectedItems(), sender: self)
        } else {
            threeDotsManager.showActions(for: shareType, sender: self)
        }
    }
    
    private func showPlusButton() {
        let menuItems = floatingButtonsArray.map { buttonType in
            AlertFilesAction(title: buttonType.title, icon: buttonType.image) { [weak self] in
                self?.customTabBarController?.handleAction(buttonType.action)
            }
        }

        let menu = AlertFilesActionsViewController()
        menu.configure(with: menuItems)
        menu.presentAsDrawer()
    }
    
    func configureCountView(isShown: Bool) {
        countView.removeFromSuperview()
        
        if isShown {
            headerStackView.addArrangedSubview(countView)
        }
    }
    
    func onlyOfficeGetFilter(documentType: OnlyOfficeFilterType) {
        collectionManager.filterOfficeReload(documentType: documentType, completion: { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.collectionManager.itemsCount == 0 {
                let message = String(format: localized(.officeFilterNotFound), documentType.description)
                SnackbarManager.shared.show(type: .nonCritical, message: message)
                self.collectionManager.filterOfficeReload(documentType: self.collectionManager.lastSelectDocumentType, completion: {})
            }
        })
    }
}


//MARK: - GridListTopBarDelegate
extension PrivateShareSharedFilesViewController: GridListTopBarDelegate {
    func onMoreButton() {
        moreButtonTapped()
    }
    
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
        configureCountView(isShown: true)
    }
    
    func didEndSelection() {
        updateBars(isSelecting: false)
    }
    
    func didChangeSelection(selectedItems: [WrapData]) {
        show(selectedItemsCount: selectedItems.count)
        bottomBarManager.update(for: selectedItems)
        countView.setCountLabel(with: selectedItems.count)
        
        if selectedItems.isEmpty {
            bottomBarManager.hide()
        } else {
            bottomBarManager.show()
        }
    }
    
    func didEndReload() {
        hideSpinner()
        
        navBarManager.threeDotsButton.isEnabled = shareType.isSelectionAllowed && !collectionManager.isCollectionEmpty
        
        if collectionManager.isCollectionEmpty {
            setupCollectionViewBar(moreButtonIsHidden: false)
        } else {
            setupCollectionViewBar(moreButtonIsHidden: true)
        }
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
                self.navBarManager.threeDotsButton.isEnabled = !(isSelecting || self.collectionManager.isCollectionEmpty)
            }
            if isSelecting {
                let selectedItems = self.collectionManager.selectedItems()
                self.countView.setCountLabel(with: selectedItems.count)
                self.show(selectedItemsCount: selectedItems.count)
                if !selectedItems.isEmpty {
                    self.bottomBarManager.show()
                }
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
            let isShowPlusMenu = self.shareType.showPlusMenu
            
            if editingMode, isSelectionAllowed {
                self.navBarManager.setSelectionMode()
            } else {
                if !isShowPlusMenu {
                    self.navBarManager.setDefaultModeWithoutPlusButton(title: self.title ?? "")
                } else {
                    //to don't change the state of the 3dots button
                    self.navBarManager.setDefaultMode(title: self.title ?? "")
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
        moreButtonTapped()
    }
    
    func onSearchButton() {
        showSearchScreen()
    }
    
    func onPlusButton() {
        showPlusButton()
    }
    
    //MARK: Helpers
    private func showSearchScreen() {
        let controller = router.searchView(navigationController: navigationController)
        router.pushViewController(viewController: controller)
    }
}


extension PrivateShareSharedFilesViewController: BaseItemInputPassingProtocol {
    
    func onlyOfficeFilterSuccess(documentType: OnlyOfficeFilterType, items: [WrapData]) {
        onlyOfficeGetFilter(documentType: documentType)
    }
    
    func selectModeSelected() {
        collectionManager.startSelection()
    }
    
    func stopModeSelected() {
        collectionManager.endSelection()
        configureCountView(isShown: false)
    }
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
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
    
    func changePeopleThumbnail() {}
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
        if shareType.rootType == .withMe {
            collectionManager.delete(uuids: items.compactMap { $0.uuid })
        }
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
            self.collectionView.contentInset.top = h
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

extension PrivateShareSharedFilesViewController: GridListCountViewDelegate {
    func cancelSelection() {
        stopModeSelected()
    }
}

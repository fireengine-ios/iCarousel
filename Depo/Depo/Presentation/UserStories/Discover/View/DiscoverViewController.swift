//
//  DiscoverViewController.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

final class DiscoverViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var output: DiscoverViewOutput!
    var navBarConfigurator = NavigationBarConfigurator()
    var isNeedShowSpotlight = true
    let discoverDataSource = DiscoverCollectionViewDataSource()
    private var refreshControl = UIRefreshControl()
    private lazy var shareCardContentManager = ShareCardContentManager(delegate: self)
    
    private var discoverIsActiveAndVisible: Bool {
        var result = false
        if let topController = navigationController?.topViewController, topController == self {
            result = true
        }
        return result
    }
    private var isGiftButtonEnabled = false
    
    deinit {
        CardsManager.default.removeViewForNotification(view: discoverDataSource)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugLog("Discover viewDidLoad")
        needToShowTabBar = true
        navigationBarHidden = true
        discoverDataSource.configurateWith(collectionView: collectionView, viewController: self, delegate: self)
        CardsManager.default.addViewForNotification(view: discoverDataSource)
        configurateRefreshControl()
        showSpinner()
        setDefaultNavigationHeaderActions()
        output.viewIsReady()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavigationItemsState(state: true)
        if let searchController = navigationController?.topViewController as? SearchViewController {
            searchController.dismissController(animated: false)
        }
        output.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        debugLog("Discover viewDidAppear")
        discoverDataSource.isViewActive = true
        CardsManager.default.updateAllProgressesInCardsForView(view: discoverDataSource)
        if discoverIsActiveAndVisible {
            configureNavBarActions()
        }
        if isNeedShowSpotlight {
            requestShowSpotlight()
        } else {
            isNeedShowSpotlight = true
        }
        output.viewIsReadyForPopUps()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        discoverDataSource.isViewActive = false
        hideSpotlightIfNeeded()
    }
    
    func updateNavigationItemsState(state: Bool) {
        guard let items = navigationItem.rightBarButtonItems else {
            return
        }
        for item in items {
            item.isEnabled = state
        }
    }

    //MARK: Search
    func configureNavBarActions() {
        let search = NavBarWithAction(navItem: NavigationBarList().search, action: { [weak self] _ in
            self?.updateNavigationItemsState(state: false)
            self?.output.showSearch(output: self)
        })
        let setting = NavBarWithAction(navItem: NavigationBarList().settings, action: { [weak self] _ in
            self?.updateNavigationItemsState(state: false)
            self?.output.showSettings()
        })
        navBarConfigurator.configure(right: [search, setting], left: [])
        if isGiftButtonEnabled {
            let gift = NavBarWithAction(navItem: NavigationBarList().gift, action: { [weak self] _ in
                self?.output.giftButtonPressed()
            })
            navBarConfigurator.append(rightButton: gift, leftButton: nil)
        }
        navigationItem.leftBarButtonItems = navBarConfigurator.leftItems
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }
    
    @objc func reloadData() {
        showSpinner()
        refreshControl.endRefreshing()
        output.needRefresh()
    }
    
    //MARK: Utility Methods(private)
    private func configurateRefreshControl() {
        refreshControl.tintColor = ColorConstants.whiteColor
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    private func hideSpotlightIfNeeded() {
        if let spotlight = presentedViewController as? SpotlightViewController {
            spotlight.dismiss(animated: true, completion: nil)
        }
    }
}

extension DiscoverViewController: HeaderContainingViewControllerChild {
    var scrollViewForHeaderTracking: UIScrollView? {
        return collectionView
    }
}

extension DiscoverViewController: DiscoverCollectionViewDataSourceDelegate {
    
    //MARK: CardsShareButtonDelegate
    
    func share(item: BaseDataSourceItem, type: CardShareType) {
        shareCardContentManager.presentSharingMenu(item: item, type: type)
    }
    
    //MARK: DiscoverCollectionViewDataSourceDelegate
    func onCellHasBeenRemovedWith(controller: UIViewController) { }
    
    func numberOfColumns() -> Int {
        return Device.isIpad ? 2 : 1
    }
    
    func didReloadCollectionView(_ collectionView: UICollectionView) {
        requestShowSpotlight()
    }
    
    // MARK: - DiscoverCollectionViewDataSourceDelegate Private Utility Methods
    
    private func requestShowSpotlight() {
        var cardTypes: [SpotlightType] = [.homePageIcon, .homePageGeneral]
        cardTypes.append(contentsOf: discoverDataSource.cards.compactMap { SpotlightType(cardView: $0) })
        output.requestShowSpotlight(for: cardTypes)
    }
}

extension DiscoverViewController: DiscoverViewInput {
    
    func showSnackBarWithMessage(message: String) {
        SnackbarManager.shared.show(type: .action, message: message)
    }
    
    func stopRefresh() {
        hideSpinner()
    }
    
    func startSpinner() {
        showSpinner()
    }
    
    //MARK: Spotlight
    func needShowSpotlight(type: SpotlightType) {
        guard let tabBarVC = UIApplication.topController() as? TabBarViewController else {
            return
        }
        
        frameForSpotlight(type: type, controller: tabBarVC) { [weak self] frame in
            guard
                let navVC = tabBarVC.activeNavigationController,
                navVC.topViewController is DiscoverViewController,
                frame != .zero
            else {
                return
            }
            
            let controller = SpotlightViewController.with(rect: frame, message: type.title) { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.output.shownSpotlight(type: type)
                self.output.closedSpotlight(type: type)
            }
            
            tabBarVC.present(controller, animated: true)
        }
    }
    
    func showGiftBox() {
        isGiftButtonEnabled = true
        configureNavBarActions()
    }
    
    func hideGiftBox() {
        isGiftButtonEnabled = false
        configureNavBarActions()
    }
    
    func closePermissionPopUp() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - DiscoverViewInput Private Utility Methods
    
    private func frameForSpotlight(type: SpotlightType, controller: TabBarViewController, completion: @escaping (_ frame: CGRect) -> ()) {
        var frame: CGRect = .zero
        
        switch type {
        case .homePageIcon:
            let frameBounds = controller.frameForTabAtIndex(index: 0)
            frame = controller.tabBar.convert(frameBounds, to: controller.contentView)
            if !Device.operationSystemVersionLessThen(11) {
                frame.origin.y -= UIApplication.shared.statusBarFrame.height
            }
            completion(frame)
            
        case .homePageGeneral:
            guard let premiumCardFrame = discoverDataSource.cards.first?.frame else {
                assertionFailure("premiumCard should be presented")
                completion(.zero)
                return
            }
            
            let verticalSpace: CGFloat = 20
            let navBarHeight: CGFloat = 44
            
            frame = CGRect(x: 0,
                           y: premiumCardFrame.height + navBarHeight + verticalSpace,
                           width: premiumCardFrame.width,
                           height: collectionView.frame.height - premiumCardFrame.height - verticalSpace)
            
            completion(frame)
            
        case .movieCard, .albumCard, .collageCard, .filterCard, .animationCard:
            cellCoordinates(cellType: type.cellType, to: controller.contentView, completion: completion)
            
        }
    }
    
    // MARK: - DiscoverViewInput Private Utility Methods
    
    private func cellCoordinates<T: BaseCardView>(cellType: T.Type, to: UIView, completion: @escaping (_ frame: CGRect) -> ()) {
        for (row, popupView) in discoverDataSource.cards.enumerated() {
            if type(of: popupView) == cellType {
                let indexPath = IndexPath(row: row, section: 0)
                let indexPathsVisibleCells = collectionView.indexPathsForVisibleItems.sorted { first, second -> Bool in
                    return first < second
                }
                
                if indexPathsVisibleCells.contains(indexPath) {
                    if indexPath == indexPathsVisibleCells.first {
                        collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    } else {
                        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
                    }
                    
                    var frame = popupView.convert(popupView.bounds, to: to)
                    frame.origin.y = max(0, frame.origin.y)
                    frame.size.height = popupView.spotlightHeight()
                    completion(frame)
                } else {
                    guard let layout = collectionView.collectionViewLayout as? DiscoverCollectionViewLayout else {
                        completion(.zero)
                        return
                    }
                    
                    CATransaction.flush()
                    
                    let offset = layout.frameFor(indexPath: indexPath).origin.y
                    
                    let isLastCell = indexPath.row == discoverDataSource.cards.count - 1
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        if isLastCell {
                            self.collectionView.scrollToBottom(animated: false)
                        } else {
                            self.collectionView.setContentOffset(CGPoint(x: 0, y: offset - 50), animated: false)
                        }
                    }, completion: { _ in
                        var frame = popupView.convert(popupView.bounds, to: to)
                        frame.origin.y = max(0, frame.origin.y)
                        frame.size.height = popupView.spotlightHeight()
                        completion(frame)
                        
                    })
                }
                return
            }
        }
        
        completion (.zero)
    }
}

extension DiscoverViewController: HomeViewTopViewActions {
    
    func allFilesButtonGotPressed() {
        output.allFilesPressed()
    }
    
    func createAStoryButtonGotPressed() {
        output.createStory()
    }
    
    func favoritesButtonGotPressed() {
        output.favoritesPressed()
    }
    
    func syncContactsButtonGotPressed() {
        output.onSyncContacts()
    }
}

// MARK: - SearchModuleOutput
extension DiscoverViewController: SearchModuleOutput {
    
    func cancelSearch() { }
    
    func previewSearchResultsHide() { }
    
}


extension DiscoverViewController: ShareCardContentManagerDelegate {
    func shareOperationStarted() {
        showSpinner()
    }
    
    func shareOperationFinished() {
        hideSpinner()
    }
}


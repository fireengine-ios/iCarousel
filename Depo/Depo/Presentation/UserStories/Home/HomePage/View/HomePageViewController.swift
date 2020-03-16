//
//  HomePageHomePageViewController.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class HomePageViewController: BaseViewController {

    //MARK: IBOutlet
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Properties
    var output: HomePageViewOutput!
    
    var navBarConfigurator = NavigationBarConfigurator()
    
    ///special flag for delaying spotlight present if after appearing new contorller(s) will be presented/pushed
    var isNeedShowSpotlight = true
    
    let homePageDataSource = HomeCollectionViewDataSource()
    
    private var refreshControl = UIRefreshControl()

    private var topView: UIView?
    
    private var homepageIsActiveAndVisible: Bool {
        var result = false
        if let topController = navigationController?.topViewController, topController == self {
            result = true
        }
        return result
    }
    
    private var isGiftButtonEnabled = false
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        needToShowTabBar = true
        
        debugLog("HomePage viewDidLoad")
        homePageDataSource.configurateWith(collectionView: collectionView, viewController: self, delegate: self)
        debugLog("HomePage DataSource setuped")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        CardsManager.default.addViewForNotification(view: homePageDataSource)
        
        configurateRefreshControl()
        
        showSpinner()
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavigationItemsState(state: true)
        
        CardsManager.default.updateAllProgressesInCardsForView(view: homePageDataSource)
                
        if let searchController = navigationController?.topViewController as? SearchViewController {
            searchController.dismissController(animated: false)
        }
        
        homePageNavigationBarStyle()
        
        output.viewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        debugLog("HomePage viewDidAppear")
        
        homePageDataSource.isViewActive = true

        if homepageIsActiveAndVisible {
            homePageNavigationBarStyle()
            configureNavBarActions()
        } else {
            navigationBarWithGradientStyle()
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
        homePageDataSource.isViewActive = false

        hideSpotlightIfNeeded()
    }
    
    deinit {
        CardsManager.default.removeViewForNotification(view: homePageDataSource)
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
        navBarConfigurator.configure(right: [setting, search], left: [])
        if isGiftButtonEnabled {
            let gift = NavBarWithAction(navItem: NavigationBarList().gift, action: { [weak self] _ in
                self?.output.giftButtonPressed()
            })
            navBarConfigurator.append(rightButton: gift, leftButton: nil)
        }
        
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
    
    //in case if we push new controller
    private func hideSpotlightIfNeeded() {
        if let spotlight = presentedViewController as? SpotlightViewController {
            spotlight.dismiss(animated: true, completion: nil)
        }
    }
    
}

// MARK: - HomeCollectionViewDataSourceDelegate
extension HomePageViewController: HomeCollectionViewDataSourceDelegate {
    
    //MARK: HomeCollectionViewDataSourceDelegate
    func onCellHasBeenRemovedWith(controller: UIViewController) { }
    
    func numberOfColumns() -> Int {
        return Device.isIpad ? 2 : 1
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return HomeViewTopView.getHeight()
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HomeViewTopView", for: indexPath)
            if let headerView = headerView as? HomeViewTopView {
                headerView.actionsDelegate = self
            }
            topView = headerView
            return headerView
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    func didReloadCollectionView(_ collectionView: UICollectionView) {
        requestShowSpotlight()
    }
    
    // MARK: - HomeCollectionViewDataSourceDelegate Private Utility Methods
    
    private func requestShowSpotlight() {
        var cardTypes: [SpotlightType] = [.homePageIcon, .homePageGeneral]
        cardTypes.append(contentsOf: homePageDataSource.cards.compactMap { SpotlightType(cardView: $0) })
        output.requestShowSpotlight(for: cardTypes)
    }
}

//MARK: - HomePageViewInput
extension HomePageViewController: HomePageViewInput {
    
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
                navVC.topViewController is HomePageViewController,
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
    
    // MARK: - HomePageViewInput Private Utility Methods
    
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
            guard let premiumCardFrame = homePageDataSource.cards.first?.frame else {
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
    
    // MARK: - HomePageViewInput Private Utility Methods
    
    private func cellCoordinates<T: BaseCardView>(cellType: T.Type, to: UIView, completion: @escaping (_ frame: CGRect) -> ()) {
        for (row, popupView) in homePageDataSource.cards.enumerated() {
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
                    guard let layout = collectionView.collectionViewLayout as? HomeCollectionViewLayout else {
                        completion(.zero)
                        return
                    }
                    
                    CATransaction.flush() //rendering what is already ready
                    
                    let offset = layout.frameFor(indexPath: indexPath).origin.y
                    
                    let isLastCell = indexPath.row == homePageDataSource.cards.count - 1
                    
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

//MARK: - HomeViewTopViewActions
extension HomePageViewController: HomeViewTopViewActions {
    
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
extension HomePageViewController: SearchModuleOutput {
    
    func cancelSearch() { }
    
    func previewSearchResultsHide() { }
    
}

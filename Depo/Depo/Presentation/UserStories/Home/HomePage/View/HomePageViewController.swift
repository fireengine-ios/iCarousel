//
//  HomePageHomePageViewController.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class HomePageViewController: BaseViewController, HomePageViewInput, BaseCollectionViewDataSourceDelegate, UICollectionViewDelegate, SearchModuleOutput {

    var output: HomePageViewOutput!

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var refreshControl = UIRefreshControl()
    
    let homePageDataSource = BaseCollectionViewDataSource()
    
    var navBarConfigurator = NavigationBarConfigurator()
    
    private var topView: UIView?
    
    private var homepageIsActiveAndVisible: Bool {
        var result = false
        if let topController = navigationController?.topViewController {
            if topController == self {
                result = true
            }
        }
        return result
    }
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        needShowTabBar = true
        
        let headerNib = UINib(nibName: "HomeViewTopView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HomeViewTopView")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        homePageDataSource.configurateWith(collectionView: collectionView, viewController: self, delegate: self)
        
        configurateRefreshControl()
        
        showSpiner()
        output.homePagePresented()
    }
    
    private func configurateRefreshControl() {
        refreshControl.tintColor = ColorConstants.whiteColor
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationItemsState(state: true)
        
        output.viewIsReady()
        
        if let searchController = navigationController?.topViewController as? SearchViewController {
            searchController.dismissController(animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        homePageDataSource.isActive = true
        CardsManager.default.addViewForNotification(view: homePageDataSource)
        if homepageIsActiveAndVisible {
            homePageNavigationBarStyle()
            configureNavBarActions()
        } else {
            navigationBarWithGradientStyle()
        }
        
        output.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        homePageDataSource.isActive = false
    }
    
    deinit {
        CardsManager.default.removeViewForNotification(view: homePageDataSource)
    }

    // MARK: - SearchBarButtonPressed
    
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
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
        
    }
    
    func updateNavigationItemsState(state: Bool) {
        guard let items = navigationItem.rightBarButtonItems else {
            return
        }
        
        for item in items {
            item.isEnabled = state
        }
    }
        
    // MARK: HomePageViewInput
    
    func stopRefresh() {
        hideSpiner()
    }
    
    func needPresentPopUp(popUpView: UIViewController) {
        present(popUpView, animated: true, completion: nil)
    }
    
    func needShowSpotlight(type: SpotlightType) {        
        guard let tabBarVC = UIApplication.topController() as? TabBarViewController else {
            return
        }
        
        frameForSpotlight(type: type, controller: tabBarVC) { [weak self] frame in
            if frame != .zero {
                
                let controller = SpotlightViewController.with(rect: frame, message: type.title, completion: { [weak self] in
                    self?.output.closedSpotlight(type: type)
                })
                
                tabBarVC.present(controller, animated: true, completion: {
                    self?.output.shownSpotlight(type: type)
                })
            }
        }
    }
    
    private func frameForSpotlight(type: SpotlightType, controller: TabBarViewController, completion: @escaping (_ frame: CGRect) -> ()) {
        var frame: CGRect = .zero
        
        switch type {
        case .homePageIcon:
            let buttonFrame = controller.frameForTabAtIndex(index: 0)
            frame = controller.tabBar.convert(buttonFrame, to: controller.contentView)
            completion(frame)
        case .homePageGeneral:
            if let topView = topView {
                let topViewFrame = topView.convert(topView.frame, to: controller.contentView)
                frame = CGRect(x: 0, y: topViewFrame.maxY, width: topViewFrame.width, height: collectionView.frame.height - topViewFrame.height)
                completion(frame)
            }
        case .movieCard, .albumCard, .collageCard, .animationCard, .filterCard:
            cellCoordinates(cellType: type.cellType, to: controller.contentView, completion: completion)
        }
    }
    
    private func cellCoordinates<T: BaseView>(cellType: T.Type, to: UIView, completion: @escaping (_ frame: CGRect) -> ()) {
        for (row, popupView) in homePageDataSource.popUps.enumerated() {
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
                    
                    var frame = popupView.convert(popupView.frame, to: to)
                    frame.origin.y = max(0, frame.origin.y)
                    frame.size.height = popupView.spotlightHeight()
                    completion(frame)
                } else {
                    guard let layout = collectionView.collectionViewLayout as? CollectionViewLayout else {
                        completion(.zero)
                        return
                    }

                    CATransaction.flush() //rendering what is already ready
        
                    let offset = layout.frameFor(indexPath: indexPath).origin.y
                    
                    let isLastCell = indexPath.row == homePageDataSource.popUps.count - 1
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        if isLastCell {
                            self.collectionView.scrollToBottom(animated: false)
                        } else {
                             self.collectionView.setContentOffset(CGPoint(x: 0, y: offset - 50), animated: false)
                        }
                    }, completion: { _ in
                        var frame = popupView.convert(popupView.frame, to: to)
                        frame.origin.y = max(0, frame.origin.y)
                        frame.size.height = popupView.spotlightHeight()
                        completion(frame)

                    })
                }
            }
        }
        completion (.zero)
    }
    
    // MARK: BaseCollectionViewDataSourceDelegate
    
    func onCellHasBeenRemovedWith(controller: UIViewController) {
        
    }
    
    func numberOfColumns() -> Int {
        if (Device.isIpad) {
            return 2
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return HomeViewTopView.getHeight()
    }
    
    func didReloadCollectionView(_ collectionView: UICollectionView) {
        output.didReloadCollectionView()
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
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
    
    func cancelSearch() { }
    
    func previewSearchResultsHide() { }
    
    @objc func reloadData() {
        showSpiner()
        refreshControl.endRefreshing()
        output.needRefresh()
    }
    
}


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

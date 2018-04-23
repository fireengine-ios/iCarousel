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

        var frame: CGRect = .zero
        
        switch type {
        case .homePageIcon:
            frame = CGRect(x: 0, y: tabBarVC.tabBar.frame.minY, width: 60, height: tabBarVC.tabBar.frame.height)
            
        case .homePageGeneral:
            if let topView = topView {
                let topViewFrame = topView.convert(topView.frame, to: tabBarVC.contentView)
                frame = CGRect(x: 0, y: topViewFrame.maxY, width: topViewFrame.width, height: collectionView.frame.height - topViewFrame.height)
            }
        case .movieCard, .albumCard, .collageCard, .animationCard, .filterCard:
            frame = cellCoordinates(cellType: type.cellType, to: tabBarVC.contentView)
        }
        
        if frame != .zero {
            let controller = SpotlightViewController.with(rect: frame, message: type.title)
            
            tabBarVC.present(controller, animated: true, completion: {
                self.output.shownSpotlight(type: type)
            })
        }
    }
    
    private func cellCoordinates<T: BaseView>(cellType: T.Type, to: UIView) -> CGRect {
        for (row, cell) in homePageDataSource.popUps.enumerated() {
            if type(of: cell) == cellType {
                collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .bottom, animated: false)
                return cell.convert(cell.frame, to: to)
            }
        }
        return .zero
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

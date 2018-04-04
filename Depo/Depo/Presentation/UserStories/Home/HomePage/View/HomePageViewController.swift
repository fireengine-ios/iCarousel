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
    
    var refresher: UIRefreshControl!
    
    let homePageDataSource = BaseCollectionViewDataSource()
    
    var navBarConfigurator = NavigationBarConfigurator()
    
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
        
        refresher = UIRefreshControl()
        refresher.tintColor = ColorConstants.whiteColor
        refresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
        showSpiner()
        output.homePagePresented()
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
        refresher.endRefreshing()
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

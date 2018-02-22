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
    
    let homePageDataSource = BaseCollectionViewDataSource()
    
    var navBarConfigurator = NavigationBarConfigurator()
    
    private var _searchViewController: UIViewController?
    private var searchViewController: UIViewController! {
        get {
            if let svc = _searchViewController {
                return svc
            } else {
                let router = RouterVC()
                let searchViewController = router.searchView(output: self)                
                _searchViewController = searchViewController
                return _searchViewController!
            }
        }
        set (new) {
            _searchViewController = new
        }
    }
    
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
        
        output.homePagePresented()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        output.viewIsReady()
        
        if _searchViewController != nil {
            let router = RouterVC()
            router.pushViewController(viewController: searchViewController)
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
    
    deinit{
        CardsManager.default.removeViewForNotification(view: homePageDataSource)
    }

    // MARK: - SearchBarButtonPressed
    
    func configureNavBarActions() {
        let search = NavBarWithAction(navItem: NavigationBarList().search, action: { [weak self] (_) in
            guard let `self` = self else {
                return
            }
            let router = RouterVC()
            router.pushViewController(viewController: self.searchViewController)
        })
        let setting = NavBarWithAction(navItem: NavigationBarList().settings, action: { [weak self] _ in
            self?.output.showSettings()
        })
        navBarConfigurator.configure(right: [setting, search], left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }

    
    // MARK: HomePageViewInput
    
    func setupInitialState() {
        
    }
    
    
    //MARK: BaseCollectionViewDataSourceDelegate
    
    func onCellHasBeenRemovedWith(controller:UIViewController){
        
    }
    
    func numberOfColumns() -> Int{
        if (Device.isIpad){
            return 2
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat{
        return HomeViewTopView.getHeight()
    }
    
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView{
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
    
    func cancelSearch() {
        searchViewController = nil
    }
    
    func previewSearchResultsHide() { }
    
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

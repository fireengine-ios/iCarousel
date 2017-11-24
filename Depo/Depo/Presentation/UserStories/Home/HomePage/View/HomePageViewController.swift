//
//  HomePageHomePageViewController.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController, HomePageViewInput, BaseCollectionViewDataSourceDelegate, UICollectionViewDelegate, SearchModuleOutput {

    var output: HomePageViewOutput!
    
    var navBarConfigure = NavigationBarConfigurator()

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
                searchViewController.modalPresentationStyle = .overCurrentContext
                searchViewController.modalTransitionStyle = .crossDissolve
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
        
        let headerNib = UINib(nibName: "HomeViewTopView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HomeViewTopView")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        var controllersArray = [UIViewController]()
        
        let viewContr0 = WelcomeModuleInitializer.initializeViewController(with: "WelcomeViewController")
        let viewContr1 = CompleteProfileModuleInitializer.initializeViewController(with: "CompleteProfileViewController")
        let viewContr2 = WiFiSyncModuleInitializer.initializeViewController(with: "WiFiSyncViewController")
        let viewContr3 = ExpandStorageModuleInitializer.initializeViewController(with: "ExpandStorageViewController")
        let viewContr4 = UploadedItemsModuleInitializer.initializeViewController(with: "UploadedItemsViewController")
        let viewContr5 = LikeFilterModuleInitializer.initializeViewController(with: "LikeFilterViewController")
        
        if (Device.isIpad){
            controllersArray.append(viewContr0)
            controllersArray.append(viewContr1)
            controllersArray.append(viewContr2)
            controllersArray.append(viewContr3)
            controllersArray.append(viewContr4)
            controllersArray.append(viewContr5)
        }else{
            controllersArray.append(viewContr0)
            controllersArray.append(viewContr2)
            controllersArray.append(viewContr4)
            controllersArray.append(viewContr1)
            controllersArray.append(viewContr3)
            controllersArray.append(viewContr5)
        }
        homePageDataSource.configurateWith(collectionView: collectionView, viewController: self, data: controllersArray, delegate: self)
        
        output.homePagePresented()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationName = NSNotification.Name(rawValue: TabBarViewController.notificationShowTabBar)
        NotificationCenter.default.post(name: notificationName, object: nil)
        
        output.viewIsReady()
        
        if _searchViewController != nil {
            let router = RouterVC()
            router.rootViewController?.present(self.searchViewController, animated: false, completion: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        homePageDataSource.isActive = true
        WrapItemOperatonManager.default.addViewForNotification(view: homePageDataSource)
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
        WrapItemOperatonManager.default.removeViewForNotification(view: homePageDataSource)
    }

    // MARK: - SearchBarButtonPressed
    
    func configureNavBarActions() {
        let search = NavBarWithAction(navItem: NavigationBarList().search, action: { [weak self] (_) in
            guard let `self` = self else {
                return
            }
            let router = RouterVC()
            router.rootViewController?.present(self.searchViewController, animated: true, completion: nil)
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

//
//  HiddenPhotosViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 12/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class HiddenPhotosViewController: BaseViewController, NibInit {

    @IBOutlet private weak var sortPanelContainer: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private lazy var dataSource = HiddenPhotosDataSource(collectionView: collectionView, delegate: self)
    private lazy var sortingManager = HiddenPhotosSortingManager(delegate: self)
    private lazy var dataLoader = HiddenPhotosDataLoader(delegate: self)
    private lazy var bottomBarManager = HiddenPhotosBottomBarManager(delegate: self)
    private lazy var navbarManager = HiddenPhotosNavbarManager(delegate: self)
    private lazy var threeDotsManager = HiddenPhotosThreeDotMenuManager(delegate: self)
    
    private lazy var router = RouterVC()
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sortingManager.addBarView(to: sortPanelContainer)
        setupRefreshControl()
        bottomBarManager.setup()
        
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        
        //need to fix crash on show bottom bar
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc private func reloadData() {
        showSpinner()
        
        dataSource.reset()
        dataLoader.reloadData()
    }
}

// MARK: - Selection State Methods

extension HiddenPhotosViewController {
    private func startSelectionState() {
        navigationItem.hidesBackButton = true
        navbarManager.setSelectionState()
    }
    
    private func stopSelectionState() {
        navigationItem.hidesBackButton = false
        dataSource.cancelSelection()
        navbarManager.setDefaultState(sortType: dataSource.sortedRule)
        bottomBarManager.hide()
        collectionView.contentInset.bottom = 0
        setMoreButton()
    }
    
    private func updateBarsForSelectedObjects(count: Int) {
        navbarManager.changeSelectionItems(count: count)

        if count == 0 {
            bottomBarManager.hide()
            collectionView.contentInset.bottom = 0
        } else {
            bottomBarManager.show()
            collectionView.contentInset.bottom = bottomBarManager.editingTabBar?.editingBar.bounds.height ?? 0
        }
    }
    
    private func setMoreButton() {
        navbarManager.setMoreButton(isEnabled: !dataSource.isEmpty)
    }
}

//MARK: - HiddenPhotosDataSourceDelegate

extension HiddenPhotosViewController: HiddenPhotosDataSourceDelegate {
    
    func needLoadNextPage() {
        dataLoader.loadNextPhotoPage()
    }
    
    func didSelect(item: Item) {
        
    }
    
    func onStartSelection() {
        startSelectionState()
    }
}

//MARK: - HiddenPhotosSortingManagerDelegate

extension HiddenPhotosViewController: HiddenPhotosSortingManagerDelegate {
    func sortingRuleChanged(rule: SortedRules) {
        dataSource.sortedRule = rule
        dataLoader.sortedRule = rule
        reloadData()
    }
}

//MARK: - HiddenPhotosDataLoaderDelegate

extension HiddenPhotosViewController: HiddenPhotosDataLoaderDelegate {
    func didLoadPhoto(items: [Item]) {
        dataSource.append(items: items)
    }
    
    func didLoadAlbum(items: [AlbumItem]) {
        
    }
}

//MARK: - HiddenPhotosBottomBarManagerDelegate

extension HiddenPhotosViewController: HiddenPhotosBottomBarManagerDelegate {
    func onBottomBarDelete() {
        
    }
    
    func onBottomBarHide() {
        
    }
}

//MARK: - HiddenPhotosNavbarManagerDelegate

extension HiddenPhotosViewController: HiddenPhotosNavbarManagerDelegate {
    func onCancel() {
       stopSelectionState()
    }
    
    func onMore(_ sender: UIBarButtonItem) {
        threeDotsManager.showActions(isSelectingMode: dataSource.isSelectionStateActive, sender: sender)
    }
    
    func onSearch() {
        let controller = router.searchView(navigationController: navigationController)
        router.pushViewController(viewController: controller)
    }
}

//MARK: - HiddenPhotosThreeDotMenuManagerDelegate

extension HiddenPhotosViewController: HiddenPhotosThreeDotMenuManagerDelegate {
    func onThreeDotsManagerHide() {
        
    }
    
    func onThreeDotsManagerSelect() {
        
    }
    
    func onThreeDotsManagerDelete() {
        
    }
}

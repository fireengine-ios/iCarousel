//
//  PhotoVideoController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PhotoVideoController: UIViewController, NibInit {

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
//            collectionView.dataSource =
        }
    }
    
    private let refresher = UIRefreshControl()
    
    lazy var cancelSelectionButton = UIBarButtonItem(
        title: TextConstants.cancelSelectionButtonTitle,
        font: .TurkcellSaturaDemFont(size: 19.0),
        target: self,
        selector: #selector(onCancelSelectionButton))
    
    var editingTabBar: BottomSelectionTabBarViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupEdittingBar()
        setupPullToRefresh()
//        collectionView.alwaysBounceVertical = true
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
    }
    
    private func setupEdittingBar() {
        let photoVideoBottomBarConfig = EditingBarConfig(
            elementsConfig:  [.share, .download, .sync, .addToAlbum, .delete], 
            style: .blackOpaque, tintColor: nil)
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        let botvarBarVC = bottomBarVCmodule.setupModule(config: photoVideoBottomBarConfig, settablePresenter: BottomSelectionTabBarPresenter())
        self.editingTabBar = botvarBarVC
    }
    
    private func setupPullToRefresh() {
        //refresher.tintColor = ColorConstants.whiteColor
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.addSubview(refresher)
    }
    
    @objc private func refreshData() {
        
    } 
    
    @objc private func onCancelSelectionButton() {
        
    }
}

//
//  HomePageAllFiles.swift
//  Depo
//
//  Created by Aleksandr on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class HomePageAllFiles: BasicCustomNavBarViewController {
    
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackButton()

////        let initialiser = BaseCollectionModuleInitializer(withDataSource: self)
////        collectionVC = initialiser.viewController
////        contentViewTopConstraint.constant = (customNavigationBar?.bounds.height)!
//        
//        
//        addChildViewController(collectionVC)
//        collectionVC.view.frame = contentView.bounds
//        contentView.addSubview(collectionVC!.view)
//        
//        collectionVC.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

//        customNavigationBar
        
//        conte

    }
    
    @IBAction func testAction(_ sender: Any) {
//        baseOutput?.inNeedOfTabBarChange()
    }
    
}

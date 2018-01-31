//
//  FaceImageFilesViewController.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImageFilesViewController: BaseFilesGreedChildrenViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(title: mainTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUgglaLogo()
    }

    override func configureNavBarActions(isSelecting: Bool = false) {
        super.configureNavBarActions(isSelecting: isSelecting)
    }
    
    private func addUgglaLogo() {
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "uggla"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.addSubview(logoImageView)
        collectionView.bringSubview(toFront: logoImageView)
        
        logoImageView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 0).isActive = true;
        logoImageView.leftAnchor.constraint(equalTo: collectionView.leftAnchor, constant: 0).isActive = true;
        logoImageView.rightAnchor.constraint(equalTo: collectionView.rightAnchor, constant: 0).isActive = true;
        logoImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true;
        logoImageView.backgroundColor = UIColor.red
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: logoImageView.frame.height + 20.0, right: 0)
        collectionView.backgroundColor = UIColor.blue
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

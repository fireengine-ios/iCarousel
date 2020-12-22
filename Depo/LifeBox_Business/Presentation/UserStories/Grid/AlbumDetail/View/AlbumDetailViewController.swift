//
//  AlbumDetailAlbumDetailViewController.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AlbumDetailViewController: BaseFilesGreedChildrenViewController {

    var album: AlbumItem?
    
    override func viewWillAppear(_ animated: Bool) {
        if let name = album?.name {
            mainTitle = name
        }
        super.viewWillAppear(animated)
        configureNavBarActions()
    }
}

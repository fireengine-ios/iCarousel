//
//  FaceImageItemPhotosViewController.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImagePhotosViewController: BaseFilesGreedChildrenViewController, FaceImagePhotosViewInput {
    
    @IBOutlet private weak var headerImage: UIImageView!
    
    func setHeaderImage(with url: URL) {
        headerImage.sd_setImage(with: url) { [weak self] (image, error, cacheType, url) in
            self?.headerImage.image = image
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(withString: mainTitle )
    }
    
    override func configurateNavigationBar() {
        configureFaceImageItemsPhotoActions()
    }
    
    override func stopSelection() {
        super.stopSelection()
        
        configureFaceImageItemsPhotoActions()
        setTitle(withString: mainTitle)
    }

}

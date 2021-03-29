//
//  UploadGalleryPickerController.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class UploadGalleryPickerController: ViewController {
    
    @IBOutlet private weak var collectionView: QuickSelectCollectionView!
    
    
    private lazy var collectionManager = UploadGalleryPickerCollectionManager(collection: collectionView)

    override func viewDidLoad() {
        super.viewDidLoad()

        //
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
}

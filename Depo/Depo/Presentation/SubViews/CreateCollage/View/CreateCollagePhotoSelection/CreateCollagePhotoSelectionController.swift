//
//  CreateCollagePhotoSelectionController.swift
//  Depo
//
//  Created by Ozan Salman on 5.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

import Foundation

final class CreateCollagePhotoSelectionController: BaseViewController {
    
    private var collageTemplate: CollageTemplateElement?
    
    init(collageTemplate: CollageTemplateElement) {
        self.collageTemplate = collageTemplate
        super.init(nibName: "CreateCollagePhotoSelection", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("CreateCollagePhotoSelectionController viewDidLoad")
        setTitle(withString: "Select Photo")
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
    }
    
}

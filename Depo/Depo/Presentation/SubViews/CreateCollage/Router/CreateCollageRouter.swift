//
//  CreateCollageRouter.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class CreateCollageRouter: CreateCollageRouterInput {
    
    private let router = RouterVC()
    weak var presenter: CreateCollagePresenter!
    
    func navigateToAlbumDetail(collageTemplate: CollageTemplateElement) {
        let vc = router.createCollagePreview(collageTemplate: collageTemplate, selectedItems: [])
        router.pushViewController(viewController: vc, animated: false)
    }
}

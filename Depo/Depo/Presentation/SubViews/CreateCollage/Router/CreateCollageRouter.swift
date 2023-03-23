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
    
    func navigateToSeeAll(collageTemplate: CollageTemplate) {
        let vc = router.createCollageNavigateToSeeAll(collageTemplate: collageTemplate)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    func navigateToCreateCollage(collageTemplate: CollageTemplateElement) {
        let vc = router.createCollagePreview(collageTemplate: collageTemplate, selectedItems: [])
        router.pushViewController(viewController: vc, animated: false)
    }
    
    func openSelectPhotosWithNew(collageTemplate: CollageTemplateElement) {
        let vc = router.createCollageSelectPhotos(collageTemplate: collageTemplate)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    func openSelectPhotosWithChange(collageTemplate: CollageTemplateElement, items: [SearchItemResponse], selectItemIndex: Int) {
        let vc = router.createCollageSelectPhotos(collageTemplate: collageTemplate, items: items, selectItemIndex: selectItemIndex)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    func openForYou() {
        router.createCollageToForyou()
    }
}

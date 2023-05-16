//
//  CreateCollagePresenter.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class CreateCollagePresenter: BasePresenter, ForYouModuleInput {

    weak var view: CreateCollageViewInput!
    var interactor: CreateCollageInteractor!
    var router: CreateCollageRouterInput!
    
    private var collageTemplateData: CollageTemplate?
    
    func viewIsReady() {
        interactor.viewIsReady()
        view.showSpinner()
    }
}

extension CreateCollagePresenter: CreateCollageViewOutput {
    
    func getSectionsCountAndName() -> [Int] {
        var keys = [Int]()
        var keysReturn = [Int]()
        let data = Dictionary(grouping: self.collageTemplateData ?? [], by: { $0.shapeCount })
        for (key, _) in data {
            keys.append(key)
        }
        keysReturn = keys.sorted()
        keys.removeAll()
        for values in keysReturn {
            if values < 5 {
                keys.append(values)
            } else {
                keys.append(values)
                break
            }
        }
        
        return keys.sorted()
    }
    
    func getSectionsCollageTemplateData(shapeCount: Int) -> CollageTemplate {
        return collageTemplateData?.filter { $0.shapeCount == shapeCount } ?? []
    }
    
    func getCollageTemplate(for collageSection: CollageTemplateSections) -> CollageTemplate {
        switch collageSection {
        case .dual:
            return collageTemplateData?.filter { $0.shapeCount == 2 } ?? []
        case .triple:
            return collageTemplateData?.filter { $0.shapeCount == 3 } ?? []
        case .quad:
            return collageTemplateData?.filter { $0.shapeCount == 4 } ?? []
        case .multiple:
            return collageTemplateData?.filter { $0.shapeCount > 4 } ?? []
        case .all:
            return collageTemplateData ?? []
        }
    }
    
    func onSeeAllButton(for section: CollageTemplateSections) {
        router.navigateToSeeAll(collageTemplate: getCollageTemplate(for: section), section: section)
    }
    
    func naviateToCollageTemplateDetail(collageTemplate: CollageTemplateElement) {
        StringConstants.collageName = localized(.createCollagePreviewMainTitle)
        router.navigateToCreateCollage(collageTemplate: collageTemplate)
    }
}

extension CreateCollagePresenter: CreateCollageInteractorOutput {
    func getCollageTemplate(data: CollageTemplate) {
        self.collageTemplateData = data
    }
    
    func didFinishedAllRequests() {
        view.hideSpinner()
        view.didFinishedAllRequests()
    }
}

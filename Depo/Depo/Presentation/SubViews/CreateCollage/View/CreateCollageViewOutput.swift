//
//  CreateCollageViewOutput.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

protocol CreateCollageViewOutput: AnyObject {
    func viewIsReady()
    func getCollageTemplate(for collageSection: CollageTemplateSections) -> CollageTemplate
    func getSectionsCountAndName() -> [Int]
    func getSectionsCollageTemplateData(shapeCount: Int) -> CollageTemplate
    func onSeeAllButton(for section: CollageTemplateSections)
    func naviateToCollageTemplateDetail(collageTemplate: CollageTemplateElement)
}

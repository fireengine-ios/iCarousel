//
//  CreateCollageRouterInput.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

protocol CreateCollageRouterInput {
    func navigateToCreateCollage(collageTemplate: CollageTemplateElement)
    func navigateToSeeAll(collageTemplate: CollageTemplate, section: CollageTemplateSections)
}

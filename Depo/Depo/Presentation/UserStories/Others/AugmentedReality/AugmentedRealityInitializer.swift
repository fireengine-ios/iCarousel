//
//  AugumentedRealityInitializer.swift
//  Depo
//
//  Created by Konstantin on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//


final class AugmentedRealityInitializer {
    
    static func initializeController(with item: WrapData) -> AugmentedRealityController {
        let vc = AugmentedRealityController()
        
        configure(controller: vc, with: item)
        
        return vc
    }
    
    static func configure(controller: AugmentedRealityController, with item: WrapData) {
        let arItem = AugmentedRealityItem(with: item)
        let dataSource = AugmentedRealityDataSource(with: arItem)
        controller.source = dataSource
    }
}

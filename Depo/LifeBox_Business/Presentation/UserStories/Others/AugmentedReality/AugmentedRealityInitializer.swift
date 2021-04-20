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
        let dataSource = AugmentedRealityDataSource(with: item)
        vc.source = dataSource
        
        return vc
    }
}

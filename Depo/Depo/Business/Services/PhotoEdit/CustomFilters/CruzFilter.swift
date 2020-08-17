//
//  CruzFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPCruzFilter: ComplexFilter {
    
    func apply(on image: MTIImage?, intensity: Float) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        return inputImage
            .adjusting(saturation: -100/255)
            .adjusting(contrast: 1.3)
            .adjusting(brightness: 20/255)
    }
}

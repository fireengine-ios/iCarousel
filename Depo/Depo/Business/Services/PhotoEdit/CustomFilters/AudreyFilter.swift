//
//  AudreyFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPAudreyFilter: ComplexFilter {
    private lazy var toneFilter: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        
        filter.redControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                   MTIVector(x:124/255, y:138/255),
                                   MTIVector(x:255/255, y:255/255)]
        
        return filter
    }()
    
    
    func apply(on image: MTIImage?, intensity: Float) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        toneFilter.inputImage = inputImage
            .adjusting(saturation: -100/255)
            .adjusting(contrast: 1.3)
            .adjusting(brightness: 20/255)
        
        return toneFilter.outputImage
    }
}

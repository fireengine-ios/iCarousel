//
//  StarlitFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPStartlitFilter: CustomFilterProtocol {
    private lazy var toneFilter: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        filter.rgbCompositeControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                            MTIVector(x:34/255, y:6/255),
                                            MTIVector(x:69/255, y:23/255),
                                            MTIVector(x:100/255, y:58/255),
                                            MTIVector(x:150/255, y:154/255),
                                            MTIVector(x:176/255, y:196/255),
                                            MTIVector(x:207/255, y:233/255),
                                            MTIVector(x:255/255, y:255/255)]
        
        return filter
    }()
    
    func apply(on image: MTIImage?, intensity: Float) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        toneFilter.intensity = intensity
        
        toneFilter.inputImage = inputImage
        
        return toneFilter.outputImage
    }
}

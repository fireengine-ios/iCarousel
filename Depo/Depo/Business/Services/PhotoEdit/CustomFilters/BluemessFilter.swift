//
//  BluemessFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPBluemessFilter: CustomFilterProtocol {
    private lazy var toneFilter: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        
        filter.redControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                   MTIVector(x:86/255, y:34/255),
                                   MTIVector(x:117/255, y:41/255),
                                   MTIVector(x:146/255, y:80/255),
                                   MTIVector(x:170/255, y:151/255),
                                   MTIVector(x:200/255, y:214/255),
                                   MTIVector(x:225/255, y:242/255),
                                   MTIVector(x:255/255, y:255/255)]
        
        return filter
    }()
    
    
    func apply(on image: MTIImage?, intensity: Float) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        toneFilter.intensity = intensity
        
        toneFilter.inputImage = inputImage
        
        return toneFilter.outputImage?
            .adjusting(brightness: 30/255)
            .adjusting(contrast: 1)
    }
}

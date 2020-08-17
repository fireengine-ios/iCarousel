//
//  LimeFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPLimeFilter: CustomFilterProtocol {
    private lazy var toneFilter: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        filter.blueControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                    MTIVector(x:165/255, y:114/255),
                                    MTIVector(x:255/255, y:255/255)]
        
        return filter
    }()
    
    var intensity: Float = 1.0
    
    let type: FilterType = .lime
    let parameters: [AdjustmentParameterProtocol]
    
    
    init(parameters: [AdjustmentParameterProtocol]) {
        self.parameters = parameters
    }
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        toneFilter.intensity = intensity
        toneFilter.inputImage = inputImage
        
        return toneFilter.outputImage
    }
}

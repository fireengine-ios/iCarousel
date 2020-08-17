//
//  ClarendonFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 18.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


protocol CustomFilterProtocol {
    var type: FilterType { get }
    var parameters: [AdjustmentParameterProtocol] { get }
    
    func apply(on image: MTIImage?, intensity: Float) -> MTIImage?
}


class MPClarendonFilter: CustomFilterProtocol {
    
    let type: FilterType = .clarendon
    let parameters: [AdjustmentParameterProtocol]
    
    private lazy var toneFilter: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        
        filter.blueControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                    MTIVector(x:33/255, y:86/255),
                                    MTIVector(x:126/255, y:220/255),
                                    MTIVector(x:255/255, y:255/255)]
        
        filter.redControlPoints = [MTIVector(x:0/255, y:0/255),
                                   MTIVector(x:56/255, y:68/255),
                                   MTIVector(x:196/255, y:206/255),
                                   MTIVector(x:255/255, y:255/255)]
        
        filter.greenControlPoints = [MTIVector(x:0/255, y:0/255),
                                     MTIVector(x:46/255, y:77/255),
                                     MTIVector(x:160/255, y:200/255),
                                     MTIVector(x:255/255, y:255/255)]
        
        return filter
    }()
    
    init(parameters: [AdjustmentParameterProtocol]) {
        self.parameters = parameters
    }
    
    
    func apply(on image: MTIImage?, intensity: Float) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        toneFilter.intensity = intensity
        
        toneFilter.intensity = intensity
        
        toneFilter.inputImage = inputImage
            .adjusting(brightness: -10/255)
            .adjusting(contrast: 1.0)
        
        
        return toneFilter.outputImage
    }
    
}

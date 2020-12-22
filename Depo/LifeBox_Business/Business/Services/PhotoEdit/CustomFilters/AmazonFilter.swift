//
//  AmazonFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPAmazonFilter: CustomFilterProtocol {
    private lazy var toneFilter: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        
        filter.blueControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                    MTIVector(x:11/255, y:40/255),
                                    MTIVector(x:36/255, y:99/255),
                                    MTIVector(x:86/255, y:151/255),
                                    MTIVector(x:167/255, y:209/255),
                                    MTIVector(x:255/255, y:255/255)]
        
        return filter
    }()
    
    var type: FilterType = .amazon
    var parameter: FilterParameterProtocol
    
    
    init(parameter: FilterParameterProtocol) {
        self.parameter = parameter
    }
    
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        toneFilter.inputImage = inputImage.adjusting(contrast: 1.2)
        let filterdImage = toneFilter.outputImage
        
        toneFilter.inputImage = nil
        
        return blend(background: image, image: filterdImage, intensity: parameter.currentValue)
    }
}

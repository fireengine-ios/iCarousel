//
//  WhisperFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPWhisperFilter: CustomFilterProtocol {
    private lazy var toneFilter: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        filter.rgbCompositeControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                            MTIVector(x:174/255, y:109/255),
                                            MTIVector(x:255/255, y:255/255)]
        
        filter.redControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                   MTIVector(x:70/255, y:114/255),
                                   MTIVector(x:157/255, y:145/255),
                                   MTIVector(x:255/255, y:255/255)]
        
        filter.greenControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                     MTIVector(x:109/255, y:138/255),
                                     MTIVector(x:255/255, y:255/255)]
        
        filter.blueControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                    MTIVector(x:113/255, y:152/255),
                                    MTIVector(x:255/255, y:255/255)]
        
        return filter
    }()
    

    let type: FilterType = .whisper
    let parameter: FilterParameterProtocol
    
    
    init(parameter: FilterParameterProtocol) {
        self.parameter = parameter
    }
    
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        toneFilter.inputImage = inputImage.adjusting(contrast: 1.5)
        
        return blend(background: image, image: toneFilter.outputImage, intensity: parameter.currentValue)
    }
}

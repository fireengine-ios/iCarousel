//
//  AweStruckFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPAweStruckFilter: CustomFilterProtocol {
    private lazy var toneFilter: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        
        filter.rgbCompositeControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                            MTIVector(x:80/255, y:43/255),
                                            MTIVector(x:149/255, y:102/255),
                                            MTIVector(x:201/255, y:173/255),
                                            MTIVector(x:255/255, y:255/255)]
        
        filter.redControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                   MTIVector(x:125/255, y:147/255),
                                   MTIVector(x:177/255, y:199/255),
                                   MTIVector(x:213/255, y:228/255),
                                   MTIVector(x:255/255, y:255/255)]
        
        filter.greenControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                     MTIVector(x:57/255, y:76/255),
                                     MTIVector(x:103/255, y:130/255),
                                     MTIVector(x:167/255, y:192/255),
                                     MTIVector(x:211/255, y:229/255),
                                     MTIVector(x:255/255, y:255/255)]
        
        filter.blueControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                    MTIVector(x:38/255, y:62/255),
                                    MTIVector(x:75/255, y:112/255),
                                    MTIVector(x:116/255, y:158/255),
                                    MTIVector(x:171/255, y:204/255),
                                    MTIVector(x:212/255, y:233/255),
                                    MTIVector(x:255/255, y:255/255)]
        
        return filter
    }()
    
    let type: FilterType = .aweStruck
    let parameter: FilterParameterProtocol
    
    
    init(parameter: FilterParameterProtocol) {
        self.parameter = parameter
    }
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        toneFilter.inputImage = inputImage
        
        return blend(background: image, image: toneFilter.outputImage, intensity: parameter.currentValue)
    }
}

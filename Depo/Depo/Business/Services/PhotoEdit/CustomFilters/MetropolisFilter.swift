//
//  MetropolisFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPMetropolisFilter: CustomFilterProtocol {
    
    let type: FilterType = .metropolis
    let parameter: FilterParameterProtocol
    
    
    init(parameter: FilterParameterProtocol) {
        self.parameter = parameter
    }
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        let output = inputImage
            .adjusting(saturation: -1/255)
            .adjusting(contrast: 1.7)
            .adjusting(brightness: 70/255)
        
        return blend(background: image, image: output, intensity: parameter.currentValue)
    }
}

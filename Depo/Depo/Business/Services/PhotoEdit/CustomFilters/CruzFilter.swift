//
//  CruzFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPCruzFilter: CustomFilterProtocol {
    
    let type: FilterType = .cruz
    let parameter: FilterParameterProtocol
    
    
    init(parameter: FilterParameterProtocol) {
        self.parameter = parameter
    }
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        let output = inputImage
            .adjusting(saturation: -100/255)
            .adjusting(contrast: 1.3)
            .adjusting(brightness: 20/255)
        
        return blend(background: image, image: output, intensity: parameter.currentValue)
    }
    
}

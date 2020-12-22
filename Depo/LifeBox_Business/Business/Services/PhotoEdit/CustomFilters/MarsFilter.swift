//
//  MarsFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPMarsFilter: CustomFilterProtocol {
    
    let type: FilterType = .mars
    let parameter: FilterParameterProtocol
    
    
    init(parameter: FilterParameterProtocol) {
        self.parameter = parameter
    }
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        let output = inputImage
            .adjusting(contrast: 1.5)
            .adjusting(brightness: 10/255)
        
        return blend(background: image, image: output, intensity: parameter.currentValue)
    }
}

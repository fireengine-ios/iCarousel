//
//  AdeleFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPAdeleFilter: CustomFilterProtocol {
    
    var type: FilterType = .adele
    var parameter: FilterParameterProtocol
    
    
    init(parameter: FilterParameterProtocol) {
        self.parameter = parameter
    }
    
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        let output = inputImage.adjusting(saturation: -100/100)
        
        return blend(background: image, image: output, intensity: parameter.currentValue)
    }
}

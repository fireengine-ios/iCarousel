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
    let parameters: [FilterParameterProtocol]
    
    var intensity: Float = 1.0
    
    
    init(parameters: [FilterParameterProtocol]) {
        self.parameters = parameters
    }
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        //TODO: intensity
        
        return inputImage
            .adjusting(saturation: -1/255)
            .adjusting(contrast: 1.7)
            .adjusting(brightness: 70/255)
    }
}

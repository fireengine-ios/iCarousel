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
    func apply(on image: MTIImage?, intensity: Float) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
        
        return inputImage
            .adjusting(contrast: 1.5)
            .adjusting(brightness: 10/255)
    }
}

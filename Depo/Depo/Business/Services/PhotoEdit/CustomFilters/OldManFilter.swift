//
//  OldManFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPOldManFilter: CustomFilterProtocol {
    
    init(parameter: FilterParameterProtocol) {
        self.parameter = parameter
    }
    
    let type: FilterType = .oldMan
    let parameter: FilterParameterProtocol
    
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image else {
            return nil
        }
    
        
        let tmpImage = inputImage
            .adjusting(brightness: 30/255)
            .adjusting(saturation: 0.8)
            .adjusting(contrast: 1.3)
        
        guard let cgImage = tmpImage.makeCGImage() else {
            return nil
        }
        
        let output = UIImage(cgImage: cgImage).adjusting(vignetteAlpha: 100).makeMTIImage()
        
        return blend(background: image, image: output, intensity: parameter.currentValue)
    }
}

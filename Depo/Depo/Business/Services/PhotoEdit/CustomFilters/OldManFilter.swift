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
    let type: FilterType = .oldMan
    let parameter: FilterParameterProtocol
    
    private let convert: MTIConvert
    
    
    init(parameter: FilterParameterProtocol, convert: MTIConvert) {
        self.parameter = parameter
        self.convert = convert
    }
    
    func apply(on image: MTIImage?) -> MTIImage? {
        let tmpImage = image?
            .adjusting(brightness: 30/255)
            .adjusting(saturation: 0.8)
            .adjusting(contrast: 1.3)
        
       guard
            let tempOutput = tmpImage,
            let output = convert.uiImage(from: tempOutput)
            
        else {
            debugLog("Can't convert to uiImage")
            return image
        }
        
        guard let imageToBlend = output.adjusting(vignetteAlpha: 100).makeMTIImage() else {
            debugLog("Can't get imageToBlend")
            return tempOutput
        }
        
        return blend(background: image, image: imageToBlend, intensity: parameter.currentValue)
    }
}

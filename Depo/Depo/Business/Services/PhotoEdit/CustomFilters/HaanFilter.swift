//
//  HaanFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPHaanFilter: CustomFilterProtocol {
    
    private lazy var toneFilter: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        
        filter.greenControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                     MTIVector(x:113/255, y:142/255),
                                     MTIVector(x:255/255, y:255/255)]
        
        return filter
    }()
    
    
    init(parameter: FilterParameterProtocol) {
        self.parameter = parameter
    }
    
    let type: FilterType = .haan
    let parameter: FilterParameterProtocol
    
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image?.makeCGImage() else {
            return nil
        }
        
        let tmpImage = UIImage(cgImage: inputImage)
        toneFilter.inputImage = tmpImage
            .adjusting(vignetteAlpha: 200).makeMTIImage()?
            .adjusting(contrast: 1.3)
            .adjusting(brightness: 60/255)
        
        return blend(background: image, image: toneFilter.outputImage, intensity: parameter.currentValue)
    }
}

//
//  AprilFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPAprilFilter: CustomFilterProtocol {
    
    private lazy var toneFilter: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        
        filter.blueControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                    MTIVector(x:39/255, y:70/255),
                                    MTIVector(x:150/255, y:200/255),
                                    MTIVector(x:255/255, y:255/255)]
        
        filter.redControlPoints = [MTIVector(x:0/255, y:0/255),
                                   MTIVector(x:45/255, y:64/255),
                                   MTIVector(x:170/255, y:190/255),
                                   MTIVector(x:255/255, y:255/255)]
        
        return filter
    }()
    
    private let convert: MTIConvert
    
    
    init(parameter: FilterParameterProtocol, convert: MTIConvert) {
        self.parameter = parameter
        self.convert = convert
    }
    
    var type: FilterType = .april
    var parameter: FilterParameterProtocol
    
    
    func apply(on image: MTIImage?) -> MTIImage? {
        
        toneFilter.inputImage = image?
            .adjusting(contrast: 1.5)
            .adjusting(brightness: 5/255)
            .adjusting(vignetteAlpha: 0.5)
        
//        guard
//            let tempOutput = toneFilter.outputImage,
//            let output = convert.uiImage(from: tempOutput)
//
//        else {
//            debugLog("Can't convert to uiImage")
//            return image
//        }
//
//        toneFilter.inputImage = nil
//
//        let imageToBlend = MTIImage(image: output.adjusting(vignetteAlpha: 150/255), colorSpace: output.cgImage?.colorSpace, isOpaque: output.isOpaque)
        
        
        return blend(background: image, image: toneFilter.outputImage, intensity: parameter.currentValue)
    }
}


extension MTIImage {
    func adjusting(vignetteAlpha: Float) -> MTIImage {
        let filter = MTIVignetteFilter()
        filter.inputImage = self
        filter.color = MTIColor(red: 0, green: 0, blue: 0, alpha: vignetteAlpha)
        return filter.outputImage!
    }
}

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
    private var mpContext: MTIContext
    
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
    
    
    init?(parameter: FilterParameterProtocol) {
        let options = MTIContextOptions()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }
        
        do {
            mpContext = try MTIContext(device: device, options: options)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        self.parameter = parameter
    }
    
    var type: FilterType = .april
    var parameter: FilterParameterProtocol
    
    
    func apply(on image: MTIImage?) -> MTIImage? {
        guard let inputImage = image, let cgImage = try? mpContext.makeCGImage(from: inputImage) else {
            return nil
        }
        
        let tmpImage = UIImage(cgImage: cgImage)
        toneFilter.inputImage = tmpImage
            .adjusting(vignetteAlpha: 150).makeMTIImage()?
            .adjusting(contrast: 1.5)
            .adjusting(brightness: 5/255)
        
        return blend(background: image, image: toneFilter.outputImage, intensity: parameter.currentValue)
    }
}

//
//  RiseFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPRiseFilter: CustomFilterProtocol {
    private var mpContext: MTIContext
    
    private lazy var toneCurve: MTIRGBToneCurveFilter = {
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
    
    
    init?() {
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
    }
    
    func apply(on image: MTIImage?, intensity: Float) -> MTIImage? {
        guard let inputImage = image, let cgImage = try? mpContext.makeCGImage(from: inputImage) else {
            return nil
        }
        
        let tmpImage = UIImage(cgImage: cgImage)
        toneCurve.inputImage = tmpImage
            .adjusting(vignetteAlpha: 200).makeMTIImage()?
            .adjusting(contrast: 1.9)
            .adjusting(brightness: 60/255)
        
        return toneCurve.outputImage
    }
}

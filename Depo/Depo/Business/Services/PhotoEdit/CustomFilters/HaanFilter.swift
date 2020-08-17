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
    private var mpContext: MTIContext
    
    private lazy var toneCurve: MTIRGBToneCurveFilter = {
        let filter = MTIRGBToneCurveFilter()
        
        filter.greenControlPoints = [MTIVector(x: 0/255, y: 0/255),
                                     MTIVector(x:113/255, y:142/255),
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
            .adjusting(contrast: 1.3)
            .adjusting(brightness: 60/255)
        
        return toneCurve.outputImage
    }
}

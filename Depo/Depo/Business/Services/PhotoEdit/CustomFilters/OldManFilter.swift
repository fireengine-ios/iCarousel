//
//  OldManFilter.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 22.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MPOldManFilter: ComplexFilter {
    private var mpContext: MTIContext
    
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
        guard let inputImage = image else {
            return nil
        }
        
        let tmpImage = inputImage
            .adjusting(brightness: 30/255)
            .adjusting(saturation: 0.8)
            .adjusting(contrast: 1.3)
        
        guard let cgImage = try? mpContext.makeCGImage(from: tmpImage) else {
            return nil
        }
        
        //TODO: color overlay
        
        return UIImage(cgImage: cgImage).adjusting(vignetteAlpha: 100).makeMTIImage()
    }
}

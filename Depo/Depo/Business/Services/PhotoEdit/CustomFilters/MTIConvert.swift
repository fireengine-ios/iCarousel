//
//  MTIConvert.swift
//  Depo_LifeTech
//
//  Created by Konstantin Studilin on 26.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


final class MTIConvert {
    
    private var mpContext: MTIContext
    
    
    init?() {
        let options = MTIContextOptions()
        options.automaticallyReclaimsResources = true
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }
        
        do {
            mpContext = try MTIContext(device: device, options: options)
        } catch {
            assertionFailure("Can't create MTIContext")
            debugLog(error.description)
            return nil
        }
    }
    
    
    func cgImage(from mtiImage: MTIImage?) -> CGImage? {
        guard let input = mtiImage else {
            return nil
        }
        
        return try? mpContext.makeCGImage(from: input)
    }
    
    func uiImage(from mtiImage: MTIImage?, scale: CGFloat, orientation: UIImageOrientation) -> UIImage? {
        guard let cgImage = cgImage(from: mtiImage) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }
    
    func uiImage(from mtiImage: MTIImage?) -> UIImage? {
        guard let cgImage = cgImage(from: mtiImage) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    deinit {
        mpContext.reclaimResources()
        mpContext.coreImageContext.clearCaches()
    }
}

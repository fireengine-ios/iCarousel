//
//  Transformation.swift
//  InstaFilter
//
//  Created by Konstantin Studilin on 26.06.2020.
//  Copyright © 2020 Konstantin. All rights reserved.
//

import Foundation
import MetalPetal


extension MTIImage {
    func makeUIImage() -> UIImage? {
        return Transformation.shared?.uiImage(from: self)
    }
}


private final class Transformation {
    static let shared = Transformation()
    
    
    private var mpContext: MTIContext
    

    private init?() {
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
    
    func uiImage(from mtiImage: MTIImage?) -> UIImage? {
        guard let input = mtiImage else {
            return nil
        }
        
        guard let cgImage = try? mpContext.makeCGImage(from: input) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

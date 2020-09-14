//
//  MTIVignetteFilter.swift
//  Depo
//
//  Created by Konstantin Studilin on 14.09.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import MetalPetal.Extension


class MTIVignetteFilter: MTIUnaryImageRenderingFilter {
    
    var color: MTIColor = .black
    var center = CGPoint(x:0.5, y:0.5)
    var start: Float = 0.3
    var end: Float = 0.75

    override var parameters: [String : Any] {
        return ["vignetteCenter": MTIVector(value: center),
                "vignetteColor": color.toFloat4(),
                "vignetteStart": start,
                "vignetteEnd": end]
    }
    
    override class func fragmentFunctionDescriptor() -> MTIFunctionDescriptor {
        return MTIFunctionDescriptor(name: "colorVignetteEffect", libraryURL: MTIDefaultLibraryURLForBundle(Bundle.main))
    }
}

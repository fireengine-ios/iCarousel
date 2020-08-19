//
//  CustomFilter.swift
//  Depo
//
//  Created by Konstantin Studilin on 17.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import MetalPetal

protocol CustomFilterProtocol {
    var type: FilterType { get }
    var parameter: FilterParameterProtocol { get }
    
    func apply(on image: MTIImage?) -> MTIImage?
}

extension CustomFilterProtocol {
    func blend(background: MTIImage?, image: MTIImage?, intensity: Float) -> MTIImage? {
        let blend = MTIBlendFilter(blendMode: .normal)
        blend.intensity = intensity
        blend.inputBackgroundImage = background
        blend.inputImage = image
        return blend.outputImage
    }
}


enum FilterType: String, CaseIterable {
    case clarendon
    case metropolis
    case lime
    case adele
    case amazon
    case april
    case audrey
    case aweStruck
    case bluemess
    case cruz
    case haan
    case mars
    case oldMan
    case rise
    case starlit
    case whisper
}

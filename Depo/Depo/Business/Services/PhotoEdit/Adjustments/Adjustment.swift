//
//  Adjustment.swift
//  Depo
//
//  Created by Konstantin Studilin on 27.07.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum AdjustmentType {
    case brightness
    case contrast
    case exposure
    case saturation
    case gamma
    case hue
    case whiteBalance
    case sepia
    case sharpen
    case vignette
    case halftone
    case crop
}

protocol AdjustmentProtocol {
    var type: AdjustmentType { get }
    var parameters: [AdjustmentParameterProtocol] { get }
    
    func applyOn(image: UIImage, onFinished: @escaping ValueHandler<UIImage>)
}


final class Adjustment: AdjustmentProtocol {
    
    let type: AdjustmentType
    let parameters: [AdjustmentParameterProtocol]

    private let thirdPartyAdjustment: ThirdPartyAdjustmentProtocol
    
    
    required init(type: AdjustmentType, parameters: [AdjustmentParameterProtocol], thirdPartyAdjustment: ThirdPartyAdjustmentProtocol) {
        self.type = type
        self.parameters = parameters
        self.thirdPartyAdjustment = thirdPartyAdjustment
    }
    
    
    func applyOn(image: UIImage, onFinished: @escaping ValueHandler<UIImage>) {
        thirdPartyAdjustment.applyOn(image: image, onFinished: onFinished)
    }

}

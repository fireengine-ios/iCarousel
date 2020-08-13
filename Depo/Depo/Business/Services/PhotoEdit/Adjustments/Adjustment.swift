//
//  Adjustment.swift
//  Depo
//
//  Created by Konstantin Studilin on 27.07.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum AdjustmentType {
    
    //light
    case brightness
    case contrast
    case exposure
    case highlightsAndShadows
    
    //color
    case whiteBalance
    case saturation
    case gamma
    
    case hsl
    //hsl
    case hue
    //case luminance - there's no such adjustment, replaced with the monochrome
    case monochrome
    
    case sharpen
    case blur
    case vignette
    
//    var parametersTypes: [AdjustmentParameterType] {
//        switch self {
//            case .brightness:
//                return [.brightness]
//            case .contrast:
//                return [.contrast]
//            case .exposure:
//                return [.exposure]
//            case .highlightsAndShadows:
//                return [.highlights, .shadows]
//            case .whiteBalance:
//                return [.temperature, .tint]
//            case .saturation:
//                return [.saturation]
//            case .gamma:
//                return [.gamma]
//            case .hue:
//                return [.hue]
//            case .monochrome:
//                return [.intensity]
//            default:
//                return []
//        }
//    }
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

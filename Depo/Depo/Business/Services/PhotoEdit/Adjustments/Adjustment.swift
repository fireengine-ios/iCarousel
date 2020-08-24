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
    
    case hue
    case monochrome
    
    //effect
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
    var hslColorParameter: HSLColorAdjustmentParameterProtocol? { get }
    
    func applyOn(image: UIImage, onFinished: @escaping ValueHandler<UIImage>)
}


final class Adjustment: AdjustmentProtocol {
    
    let type: AdjustmentType
    let parameters: [AdjustmentParameterProtocol]
    var hslColorParameter: HSLColorAdjustmentParameterProtocol?

    private let thirdPartyAdjustment: ThirdPartyAdjustmentProtocol
    
    
    required init(type: AdjustmentType, parameters: [AdjustmentParameterProtocol], hslColorParameter: HSLColorAdjustmentParameterProtocol?, thirdPartyAdjustment: ThirdPartyAdjustmentProtocol) {
        self.type = type
        self.parameters = parameters
        self.hslColorParameter = hslColorParameter
        self.thirdPartyAdjustment = thirdPartyAdjustment
    }
    
    
    func applyOn(image: UIImage, onFinished: @escaping ValueHandler<UIImage>) {
        thirdPartyAdjustment.applyOn(image: image, onFinished: onFinished)
    }

}

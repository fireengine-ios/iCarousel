//
//  AdjustmentParameter.swift
//  Depo
//
//  Created by Konstantin Studilin on 27.07.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


typealias AdjustmentParameterValues = (min: Float, max: Float, default: Float)

enum AdjustmentParameterType: String {
    case brightness
    case contrast
    case exposure
    case highlights
    case shadows
    case temperature
    case tint
    case saturation
    case gamma
    case hue
    case intensity
    case angle
    
    
    var defaultValues: AdjustmentParameterValues {
        switch self {
            case .brightness:
                return (-1, 1, 0)
            case .contrast:
                return (0, 4, 1)
            case .exposure:
                return (-10, 10, 0)
            case .saturation:
                return (0, 2, 1)
            case .gamma:
                return (0, 3, 1)
            case .hue:
                return (-180, 180, 0)
            case .temperature:
                return (4000, 7000, 5000)
            case .tint:
                return (-200, 200, 0)
            case .highlights:
                return (0, 1, 1.0)
            case .shadows:
                return (0, 1, 0)
            case .intensity:
                return (0, 1, 1)
            case .angle:
                return (-45, 45, 0)
            default:
                return (0, 0, 0)
        }
    }
}


protocol AdjustmentParameterProtocol {
    var type: AdjustmentParameterType { get }
    
    var minValue: Float { get }
    var maxValue: Float { get }
    var defaultValue: Float { get }
    var currentValue: Float { get }
    
    func set(value: Float)
    
    @discardableResult
    func onValueDidChange(handler: @escaping ValueHandler<Float>) -> AdjustmentParameterProtocol
}


final class AdjustmentParameter: AdjustmentParameterProtocol {
    
    let type: AdjustmentParameterType
    
    let minValue: Float
    let maxValue: Float
    let defaultValue: Float
    private(set) var currentValue: Float
    
    private let minMiddle: Float
    private let maxMiddle: Float
    private let middleValue: Float
    
    private var realCurrentValue: Float {
        if currentValue <= defaultValue {
            return middleValue - ((1 - currentValue / (defaultValue - minValue)) * minMiddle)
        } else {
            return middleValue + (((currentValue - defaultValue) / (maxValue - defaultValue)) * minMiddle)
        }
    }
    
    private var onValueDidChangeAction: ValueHandler<Float>?
    
    
    required init(type: AdjustmentParameterType) {
        self.type = type
        
        let defaultValues = type.defaultValues

        //ui values
        minValue = 0
        maxValue = 1
        defaultValue = 0.5
        currentValue = defaultValue
        
        //real values
        middleValue = defaultValues.default
        minMiddle = defaultValues.default - defaultValues.min
        maxMiddle = defaultValues.max - defaultValues.default
    }
    
    
    func set(value: Float) {
        currentValue = value
        onValueDidChangeAction?(realCurrentValue)
    }
    
    @discardableResult
    func onValueDidChange(handler: @escaping ValueHandler<Float>) -> AdjustmentParameterProtocol {
        onValueDidChangeAction = handler
        
        return self
    }
    
}

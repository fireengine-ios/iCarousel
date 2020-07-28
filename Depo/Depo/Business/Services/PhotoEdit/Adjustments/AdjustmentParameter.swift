//
//  AdjustmentParameter.swift
//  Depo
//
//  Created by Konstantin Studilin on 27.07.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


typealias AdjustmentParameterValues = (tag: Int, min: Float, max: Float, default: Float)

enum AdjustmentParameterType: String {
    case brightness
    case contrast
    case exposure
    case saturation
    case gamma
    case hue
    case temperature
    case tint
    
    
    var defaultValues: AdjustmentParameterValues {
        switch self {
            case .brightness:
                return (100, -1, 1, 0)
            case .contrast:
                return (101, 0, 4, 1)
            case .exposure:
                return (102, -10, 10, 0)
            case .saturation:
                return (103, 0, 2, 1)
            case .gamma:
                return (104, 0, 3, 1)
            case .hue:
                return (105, 0, 360, 90)
            case .temperature:
                return (106, 4000, 7000, 5000)
            case .tint:
                return (107, -200, 200, 0)
        }
    }
}


protocol AdjustmentParameterProtocol {
    var type: AdjustmentParameterType { get }
    
    var minValue: Float { get }
    var maxValue: Float { get }
    var defaultValue: Float { get }
    var currentValue: Float { get }
    
    @discardableResult
    func onValueDidChange(handler: @escaping ValueHandler<Float>) -> AdjustmentParameterProtocol
}


final class AdjustmentParameter: AdjustmentParameterProtocol {
    
    let type: AdjustmentParameterType
    
    let minValue: Float
    let maxValue: Float
    let defaultValue: Float
    let currentValue: Float
    
    private var onValueDidChangeAction: ValueHandler<Float>?
    
    
    required init(type: AdjustmentParameterType) {
        self.type = type
        
        let defaultValues = type.defaultValues

        minValue = defaultValues.min
        maxValue = defaultValues.max
        defaultValue = defaultValues.default
        currentValue = defaultValue
    }
    
    
    func onValueDidChange(handler: @escaping ValueHandler<Float>) -> AdjustmentParameterProtocol {
        onValueDidChangeAction = handler
        
        return self
    }
    
}

//
//  FilterParameter.swift
//  Depo
//
//  Created by Konstantin Studilin on 17.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

typealias FilterParameterValues = (min: Float, max: Float, default: Float)

enum FilterParameterType: String {
    case filterIntensity
    
    
    var defaultValues: FilterParameterValues {
        switch self {
            case .filterIntensity:
                return (0, 1, 1)
            default:
                return (0, 0, 0)
        }
    }
}


protocol FilterParameterProtocol {
    var type: FilterParameterType { get }
    
    var minValue: Float { get }
    var maxValue: Float { get }
    var defaultValue: Float { get }
    var currentValue: Float { get }
    
    func set(value: Float)
    
    @discardableResult
    func onValueDidChange(handler: @escaping ValueHandler<Float>) -> FilterParameterProtocol
}


final class FilterParameter: FilterParameterProtocol {
    
    let type: FilterParameterType
    
    let minValue: Float
    let maxValue: Float
    let defaultValue: Float
    private(set) var currentValue: Float
    
    private let minMiddle: Float
    private let maxMiddle: Float
    private let middleValue: Float
    
    private var realCurrentValue: Float {
        let real: Float
        if currentValue <= defaultValue, minMiddle != 0 {
            real = middleValue - ((1 - currentValue / (defaultValue - minValue)) * minMiddle)
        } else {
            real = middleValue + (((currentValue - defaultValue) / (maxValue - defaultValue)) * maxMiddle)
        }
        
        return real
    }
    
    private var onValueDidChangeAction: ValueHandler<Float>?
    
    
    required init(type: FilterParameterType) {
        self.type = type
        
        let defaultValues = type.defaultValues
        
        var middle: Float = 0.5
        if defaultValues.min == defaultValues.default {
            middle = 0
        } else if defaultValues.max == defaultValues.default {
            middle = 1
        }
        
        //ui values
        minValue = 0
        maxValue = 1
        defaultValue = middle
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
    func onValueDidChange(handler: @escaping ValueHandler<Float>) -> FilterParameterProtocol {
        onValueDidChangeAction = handler
        
        return self
    }
    
}

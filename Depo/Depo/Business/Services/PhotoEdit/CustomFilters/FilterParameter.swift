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
                return (0, 1, 0)
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
}


final class FilterParameter: FilterParameterProtocol {
    
    let type: FilterParameterType
    
    let minValue: Float
    let maxValue: Float
    let defaultValue: Float
    private(set) var currentValue: Float
    
    
    required init(type: FilterParameterType) {
        self.type = type
        
        let defaultValues = type.defaultValues
        
        //ui values
        minValue = defaultValues.min
        maxValue = defaultValues.max
        defaultValue = defaultValues.default
        currentValue = maxValue
    }
    
    
    func set(value: Float) {
        currentValue = value
    }
}

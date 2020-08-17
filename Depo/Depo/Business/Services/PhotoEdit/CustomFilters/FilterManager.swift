//
//  FilterManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 17.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


final class FilterManager {
    private static func filter(type: FilterType) -> CustomFilterProtocol? {
        switch type {
            case .clarendon:
                let intensityParameter = AdjustmentParameter(type: .filterIntensity)
                let filter = MPClarendonFilter(parameters: [intensityParameter])
                intensityParameter.onValueDidChange { newValue in
                    filter.intensity = newValue
                }
                return filter
            
            case .lime:
                let intensityParameter = AdjustmentParameter(type: .filterIntensity)
                let filter = MPLimeFilter(parameters: [intensityParameter])
                intensityParameter.onValueDidChange { newValue in
                    filter.intensity = newValue
                }
                return filter
            
            case .metropolis:
                let intensityParameter = AdjustmentParameter(type: .filterIntensity)
                let filter = MPMetropolisFilter(parameters: [intensityParameter])
                intensityParameter.onValueDidChange { newValue in
                    filter.intensity = newValue
                }
                return filter
            
            default:
                assertionFailure("Filter is not implemented")
                return nil
        }
    }
    
    
    let filters: [CustomFilterProtocol]
    
    
    init(types: [FilterType]) {
        filters = types.compactMap { FilterManager.filter(type: $0) }
    }
    
    
    func filteredPreviews(image: UIImage) -> [FilterType: UIImage] {
        var result = [FilterType: UIImage]()
        
        filters.forEach {
            if let filtered = $0.apply(on: image.makeMTIImage())?.makeUIImage() {
                result[$0.type] = filtered
            }
        }
        
        return result
    }
}

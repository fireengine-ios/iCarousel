//
//  FilterManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 17.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


final class FilterManager {
    private static func filter(type: FilterType) -> CustomFilterProtocol? {
        let intensityParameter = FilterParameter(type: .filterIntensity)
        
        switch type {
            case .clarendon:
                return MPClarendonFilter(parameter: intensityParameter)
            
            case .lime:
                return MPLimeFilter(parameter: intensityParameter)
            
            case .metropolis:
                return MPMetropolisFilter(parameter: intensityParameter)
            
            case .adele:
                return MPAdeleFilter(parameter: intensityParameter)
            
            case .amazon:
                return MPAmazonFilter(parameter: intensityParameter)
            
            case .april:
                return MPAprilFilter(parameter: intensityParameter)
            
            case .audrey:
                return MPAudreyFilter(parameter: intensityParameter)
            
            case .aweStruck:
                return MPAweStruckFilter(parameter: intensityParameter)
            
            case .bluemess:
                return MPBluemessFilter(parameter: intensityParameter)
            
            case .cruz:
                return MPCruzFilter(parameter: intensityParameter)
            
            case .haan:
                return MPHaanFilter(parameter: intensityParameter)
            
            case .mars:
                return MPMarsFilter(parameter: intensityParameter)
            
            case .oldMan:
                return MPOldManFilter(parameter: intensityParameter)
            
            case .rise:
                return MPRiseFilter(parameter: intensityParameter)
            
            case .starlit:
                return MPStartlitFilter(parameter: intensityParameter)
            
            case .whisper:
                return MPWhisperFilter(parameter: intensityParameter)
            
            default:
                assertionFailure("Filter is not implemented")
                return nil
        }
    }
    
    
    let filters: [CustomFilterProtocol]
    
    
    init(types: [FilterType]) {
        filters = types.compactMap { FilterManager.filter(type: $0) }
    }
    
    
    func filteredPreviews(image: UIImage?) -> [FilterType: UIImage] {
        var result = [FilterType: UIImage]()
        
        guard let source = image else {
            assertionFailure("Pass a nonnil image")
            return result
        }
        
        guard let mtiImage = source.makeMTIImage(isOpaque: source.isOpaque) else {
            return result
        }
        
        filters.forEach {
            if let filtered = $0.apply(on: mtiImage)?.makeUIImage() {
                result[$0.type] = filtered
            }
        }
        
        return result
    }
    

    func filter(image: UIImage?, type: FilterType, intensity: Float) -> UIImage? {
        guard let source = image, let filter = filters.first(where: { $0.type == type }) else {
            return image
        }
        
        guard let mtiImage = source.makeMTIImage(isOpaque: source.isOpaque) else {
            return image
        }
        
        filter.parameter.set(value: intensity)
        return filter.apply(on: mtiImage)?.makeUIImage()
    }
}

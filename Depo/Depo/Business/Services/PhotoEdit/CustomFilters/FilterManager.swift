//
//  FilterManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 17.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//


final class FilterManager {
    private static func filter(type: FilterType, convert: MTIConvert?) -> CustomFilterProtocol? {
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
                guard let convert = convert else {
                    return nil
                }
                return MPAprilFilter(parameter: intensityParameter, convert: convert)
            
            case .audrey:
                return MPAudreyFilter(parameter: intensityParameter)
            
            case .aweStruck:
                return MPAweStruckFilter(parameter: intensityParameter)
            
            case .bluemess:
                return MPBluemessFilter(parameter: intensityParameter)
            
            case .cruz:
                return MPCruzFilter(parameter: intensityParameter)
            
            case .haan:
                guard let convert = convert else {
                    return nil
                }
                return MPHaanFilter(parameter: intensityParameter, convert: convert)
            
            case .mars:
                return MPMarsFilter(parameter: intensityParameter)
            
            case .oldMan:
                guard let convert = convert else {
                    return nil
                }
                return MPOldManFilter(parameter: intensityParameter, convert: convert)
            
            case .rise:
                guard let convert = convert else {
                    return nil
                }
                return MPRiseFilter(parameter: intensityParameter, convert: convert)
            
            case .starlit:
                return MPStartlitFilter(parameter: intensityParameter)
            
            case .whisper:
                return MPWhisperFilter(parameter: intensityParameter)
            
            default:
                assertionFailure("Filter is not implemented")
                return nil
        }
    }
    
    typealias FilterConfig = (type: FilterType, intensity: Float)
    
    
    let filters: [CustomFilterProtocol]
    private(set) var lastApplied: FilterConfig?
    private var isOriginal = true
    private var appliedFilters = [FilterConfig]()
    
    private let convert: MTIConvert?
    
    
    init(types: [FilterType]) {
        let convertFromMTI = MTIConvert()
        convert = convertFromMTI
        filters = types.compactMap { FilterManager.filter(type: $0, convert: convertFromMTI) }
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
            let filtered = $0.apply(on: mtiImage)
            if let output = convert?.uiImage(from: filtered, scale: source.scale, orientation: source.imageOrientation) {
                result[$0.type] = output
            }
        }
        
        return result
    }
    
    func applyAll(image: UIImage?) -> UIImage?  {
        var resultImage = image
        
        appliedFilters.forEach { filterConfig in
            resultImage = self.filter(image: resultImage, type: filterConfig.type, intensity: filterConfig.intensity)
        }
        
        return resultImage
    }
    

    func filter(image: UIImage?, type: FilterType, intensity: Float) -> UIImage? {
        guard let source = image, let filter = filters.first(where: { $0.type == type }) else {
            return image
        }
        
        guard let mtiImage = source.makeMTIImage(isOpaque: source.isOpaque) else {
            return image
        }
        
        filter.parameter.set(value: intensity)
        lastApplied = intensity > 0 ? (type, intensity) : nil
        
        if isOriginal, lastApplied != nil {
            isOriginal = false
        }
        
        return convert?.uiImage(from: filter.apply(on: mtiImage), scale: source.scale, orientation: source.imageOrientation)
    }
    
    func saveHisory() {
        guard !isOriginal else {
            appliedFilters.removeAll()
            return
        }
        
        guard let applied = lastApplied else {
            return
        }
        
        appliedFilters.append(applied)
    }
    
    func resetToOriginal() {
        lastApplied = nil
        isOriginal = true
    }
    
    func resetLastApplied() {
        lastApplied = nil
    }
}

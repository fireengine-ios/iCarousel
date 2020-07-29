//
//  PhotoFilterViewFactory.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

enum FilterViewType {
    case adjust
    case light
    case color
    case effect
    case hls
    
        var title: String {
        switch self {
        case .adjust:
            return "Adjust"
        case .light:
            return "Light"
        case .color:
            return "Color"
        case .effect:
            return "Effect"
        case .hls:
            return "HLS"
        }
    }
}

final class PhotoFilterViewFactory {
    
    static func generateView(for type: FilterViewType, adjustmentParameters: [AdjustmentParameterProtocol], delegate: FilterSliderViewDelegate?) -> UIView? {
        switch type {
        case .adjust:
            guard let parameter = adjustmentParameters.first else {
                return nil
            }
            return AdjustFilterView.with(parameter: parameter, delegate: delegate)
        case .color:
            return ColorFilterView.with(parameters: adjustmentParameters, delegate: delegate)
        case .effect:
            return nil
        case .light:
            return LightFilterView.with(parameters: adjustmentParameters, delegate: delegate)
        case .hls:
            return HLSFilterView.with(parameters: adjustmentParameters, delegate: delegate)
        }
    }
    
    static func generateChangesBar(for type: FilterViewType, delegate: FilterChangesBarDelegate?) -> FilterChangesBar {
        return FilterChangesBar.with(title: type.title, delegate: delegate)
    }
}

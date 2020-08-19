//
//  PhotoEditViewFactory.swift
//  Depo
//
//  Created by Andrei Novikau on 7/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

enum PhotoEditViewType {
    case adjustmentView(AdjustmentViewType)
    case filterView(FilterType)
}

enum AdjustmentViewType {
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
    
    var adjustmentTypes: [AdjustmentType] {
        switch self {
        case .adjust:
            //temp
            return [.brightness]
        case .color:
            return [.whiteBalance, .saturation, .gamma]
        case .effect:
            return [.sharpen, .blur, .vignette]
        case .hls:
            return [.hsl]
        case .light:
            return [.brightness, .contrast, .exposure, .highlightsAndShadows]
        }
    }
}

final class PhotoEditViewFactory {
    
    static func generateView(for type: AdjustmentViewType, adjustmentParameters: [AdjustmentParameterProtocol], delegate: AdjustmentsViewDelegate?) -> UIView? {
        switch type {
        case .adjust:
            guard let parameter = adjustmentParameters.first else {
                return nil
            }
            return AdjustView.with(parameter: parameter, delegate: delegate)
        case .color:
            return ColorView.with(parameters: adjustmentParameters, delegate: delegate)
        case .effect:
            return LightView.with(parameters: adjustmentParameters, delegate: delegate)
        case .light:
            return LightView.with(parameters: adjustmentParameters, delegate: delegate)
        case .hls:
            return HLSView.with(parameters: adjustmentParameters, delegate: delegate)
        }
    }
    
    static func generateFilterView(_ filter: CustomFilterProtocol, delegate: PreparedFilterSliderViewDelegate?) -> PreparedFilterSliderView {
        return PreparedFilterSliderView.with(filter: filter, delegate: delegate)
    }
    
    static func generateChangesBar(with title: String, delegate: PhotoEditChangesBarDelegate?) -> PhotoEditChangesBar {
        return PhotoEditChangesBar.with(title: title, delegate: delegate)
    }
}

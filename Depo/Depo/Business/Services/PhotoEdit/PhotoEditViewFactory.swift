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
    case hsl
    
    var title: String {
        switch self {
        case .adjust:
            return TextConstants.photoEditAdjust
        case .light:
            return TextConstants.photoEditLight
        case .color:
            return TextConstants.photoEditColor
        case .effect:
            return TextConstants.photoEditEffect
        case .hsl:
            return TextConstants.photoEditHSL
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
        case .hsl:
            return [.hsl]
        case .light:
            return [.exposure, .contrast, .highlightsAndShadows, .brightness]
        }
    }
}

final class PhotoEditViewFactory {
    
    static func generateView(for type: AdjustmentViewType, adjustmentParameters: [AdjustmentParameterProtocol], adjustments: [AdjustmentProtocol], delegate: AdjustmentsViewDelegate?) -> UIView? {
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
        case .hsl:
            guard let adjustment = adjustments.first(where: { $0.type == .hsl }),
                let colorParameter = adjustment.hslColorParameter else {
                return nil
            }

            return HSLView.with(parameters: adjustmentParameters, colorParameter: colorParameter, delegate: delegate)
        }
    }
    
    static func generateFilterView(_ filter: CustomFilterProtocol, delegate: PreparedFilterSliderViewDelegate?) -> PreparedFilterSliderView {
        return PreparedFilterSliderView.with(filter: filter, delegate: delegate)
    }
    
    static func generateChangesBar(with title: String, delegate: PhotoEditChangesBarDelegate?) -> PhotoEditChangesBar {
        return PhotoEditChangesBar.with(title: title, delegate: delegate)
    }
}

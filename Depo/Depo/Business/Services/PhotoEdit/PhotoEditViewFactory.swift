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

enum PhotoEditAlertType {
    case close
    case modify
    case saveAsCopy
    
    var title: String {
        switch self {
        case .close:
            return TextConstants.photoEditCloseAlertTitle
        case .modify:
            return TextConstants.photoEditModifyAlertTitle
        case .saveAsCopy:
            return TextConstants.photoEditSaveAsCopyAlertTitle
        }
    }
    
    var message: String {
        switch self {
        case .close:
            return TextConstants.photoEditCloseAlertMessage
        case .modify:
            return TextConstants.photoEditModifyAlertMessage
        case .saveAsCopy:
            return TextConstants.photoEditSaveAsCopyAlertMessage
        }
    }
    
    var leftButtonTitle: String {
        switch self {
        case .close:
            return TextConstants.photoEditCloseAlertLeftButton
        case .modify:
            return TextConstants.photoEditModifyAlertLeftButton
        case .saveAsCopy:
            return TextConstants.photoEditSaveAsCopyAlertLeftButton
        }
    }
    
    var rightButtonTitle: String {
        switch self {
        case .close:
            return TextConstants.photoEditCloseAlertRightButton
        case .modify:
            return TextConstants.photoEditModifyAlertRightButton
        case .saveAsCopy:
            return TextConstants.photoEditSaveAsCopyAlertRightButton
        }
    }
}

final class PhotoEditViewFactory {
    
    static func generateView(for type: AdjustmentViewType, adjustmentParameters: [AdjustmentParameterProtocol], adjustments: [AdjustmentProtocol], delegate: AdjustmentsViewDelegate?) -> UIView? {
        switch type {
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
        default:
            return nil
        }
    }
    
    static func generateFilterView(_ filter: CustomFilterProtocol, delegate: PreparedFilterSliderViewDelegate?) -> PreparedFilterSliderView {
        return PreparedFilterSliderView.with(filter: filter, delegate: delegate)
    }
    
    static func generateChangesBar(with title: String, delegate: PhotoEditChangesBarDelegate?) -> PhotoEditChangesBar {
        return PhotoEditChangesBar.with(title: title, delegate: delegate)
    }
    
    static func alert(for type: PhotoEditAlertType, leftButtonHandler: VoidHandler? = nil, rightButtonHandler: VoidHandler?) -> PopUpController {
        return PopUpController.with(title: type.title,
                                    message: type.message,
                                    image: .question,
                                    firstButtonTitle: type.leftButtonTitle,
                                    secondButtonTitle: type.rightButtonTitle,
                                    firstAction: { vc in
                                        vc.close {
                                            leftButtonHandler?()
                                        }
                                    },
                                    secondAction: { vc in
                                        vc.close {
                                            rightButtonHandler?()
                                        }
                                    })
    }
}

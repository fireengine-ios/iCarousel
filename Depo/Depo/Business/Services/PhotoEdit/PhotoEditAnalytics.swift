//
//  PhotoEditAnalytics.swift
//  Depo
//
//  Created by Hady on 7/12/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import Mantis

extension PhotoEditViewController {
    class Analytics {
        private let analyticsService: AnalyticsService = factory.resolve()

        func trackClickEvent(_ event: GAEventLabel.PhotoEditEvent) {
            switch event {
            case .save, .saveAsCopy, .cancel:
                analyticsService.trackPhotoEditEvent(category: .main, eventAction: .click, eventLabel: .photoEdit(event))
            case .discard, .keepEditing:
                analyticsService.trackPhotoEditEvent(category: .popup, eventAction: .discardChanges, eventLabel: .photoEdit(event))
            default:
                return
            }
        }

        func trackClickNetmeraEvent(_ button: NetmeraEventValues.PhotoEditButton) {
            let event = NetmeraEvents.Actions.PhotoEditButtonAction(buttonName: button)
            AnalyticsService.sendNetmeraEvent(event: event)
        }

        func trackFilterScreen() {
            trackScreen(.photoEditFilters)
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.PhotoEditFiltersScreen())
        }

        func trackAdjustmentScreen() {
            trackScreen(.photoEditAdjustments)
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.PhotoEditAdjustmentScreen())
        }

        func trackGifScreen() {
            trackScreen(.photoEditGif)
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.PhotoEditGifScreen())
        }

        func trackStickerScreen() {
            trackScreen(.photoEditSticker)
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.PhotoEditStickerScreen())
        }

        private func trackScreen(_ screen: AnalyticsAppScreens) {
            analyticsService.logScreen(screen: screen)
            analyticsService.trackDimentionsEveryClickGA(screen: screen)
        }

        func trackFilter(_ type: FilterType, action: GAEventAction, netmeraAction: NetmeraEventValues.PhotoEditActionType) {
            analyticsService.trackPhotoEditEvent(category: .filters, eventAction: action, eventLabel: .photoEdit(.saveFilter(type.title)))

            let event = NetmeraEvents.Actions.PhotoEditApplyFilter(filterType: type.title, action: netmeraAction)
            AnalyticsService.sendNetmeraEvent(event: event)
        }

        func trackAdjustments(_ parameters: [AdjustmentParameterType], action: GAEventAction, netmeraAction: NetmeraEventValues.PhotoEditActionType) {
            guard !parameters.isEmpty else {
                return
            }

            parameters.forEach { parameterType in
                if let adjustment = adjustmentType(for: parameterType) {
                    analyticsService.trackPhotoEditEvent(category: .adjustments,
                                                         eventAction: action,
                                                         eventLabel: .photoEdit(.saveAdjustment(adjustment)),
                                                         filterType: parameterType.title)
                }

                if let adjustment = adjustmentNetmeraType(for: parameterType) {
                    let event = NetmeraEvents.Actions.PhotoEditApplyAdjustment(selection: adjustment,
                                                                               filterType: parameterType.title,
                                                                               action: netmeraAction)
                    AnalyticsService.sendNetmeraEvent(event: event)
                }
            }
        }

        private func adjustmentType(for type: AdjustmentParameterType) -> GAEventLabel.PhotoEditAdjustmentType? {
            switch type {
            case .brightness, .contrast, .exposure, .highlights, .shadows:
                return .light
            case .gamma, .temperature, .tint, .saturation:
                return .color
            case .hslHue, .hslLuminosity, .hslSaturation:
                return .hsl
            case .sharpness, .blurRadius, .vignetteRatio:
                return .effect
            default:
                return nil
            }
        }

        private func adjustmentNetmeraType(for type: AdjustmentParameterType) -> NetmeraEventValues.PhotoEditAdjustmentType? {
            switch type {
            case .brightness, .contrast, .exposure, .highlights, .shadows:
                return .light
            case .gamma, .temperature, .tint, .saturation:
                return .color
            case .hslHue, .hslLuminosity, .hslSaturation:
                return .hsl
            case .sharpness, .blurRadius, .vignetteRatio:
                return .effect
            default:
                return nil
            }
        }

        func trackAdjustChanges(_ transformation: Transformation, action: GAEventAction, netmeraAction: NetmeraEventValues.PhotoEditActionType) {
            var changedParameters = [String]()
            if transformation.rotation != 0 {
                changedParameters.append("Rotate")
            }
            if transformation.manualZoomed || transformation.offset != .zero || transformation.scale != 0 {
                changedParameters.append("Resize")
            }

            guard !changedParameters.isEmpty else {
                return
            }

            changedParameters.forEach { parameter in
                analyticsService.trackPhotoEditEvent(category: .adjustments,
                                                     eventAction: action,
                                                     eventLabel: .photoEdit(.saveAdjustment(.adjust)),
                                                     filterType: parameter)

                let event = NetmeraEvents.Actions.PhotoEditApplyAdjustment(selection: .adjust,
                                                                           filterType: parameter,
                                                                           action: netmeraAction)
                AnalyticsService.sendNetmeraEvent(event: event)
            }
        }

        func trackEditPhoto(success: Bool, type: NetmeraEventValues.PhotoEditType) {
            let netmeraStatus: NetmeraEventValues.GeneralStatus = success ? .success : .failure
            let event = NetmeraEvents.Actions.PhotoEditComplete(status: netmeraStatus, selection: type)
            AnalyticsService.sendNetmeraEvent(event: event)
        }

        func trackSmashSave(attachmentsLabel: String, stickerIds: [String], gifIds: [String]) {
            analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                eventActions: .smashSave,
                                                eventLabel: attachmentsLabel)

            let event = NetmeraEvents.Actions.SmashSave(action: .save,
                                                        stickerId: stickerIds,
                                                        gifId: gifIds)
            AnalyticsService.sendNetmeraEvent(event: event)
        }
    }
}

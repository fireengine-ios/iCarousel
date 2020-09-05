//
//  FilterViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import Mantis

enum PhotoEditCompletion {
    case canceled
    case saved(image: UIImage)
    case savedAs(image: UIImage)
}

typealias PhotoEditCompletionHandler = (_ controller: PhotoEditViewController, _ result: PhotoEditCompletion) -> Void

final class PhotoEditViewController: ViewController, NibInit {
    
    static func with(originalImage: UIImage, previewImage: UIImage, presented: VoidHandler?, completion: PhotoEditCompletionHandler?) -> PhotoEditViewController {
        let controller = PhotoEditViewController.initFromNib()
        controller.originalPreviewImage = previewImage
        controller.tempOriginalImage = previewImage
        controller.originalImage = originalImage
        controller.sourceImage = previewImage
        controller.presentedCallback = presented
        controller.finishedEditing = completion
        return controller
    }
    
    
    @IBOutlet private var uiManager: PhotoEditViewUIManager! {
        willSet {
            newValue.delegate = self
            newValue.navBarView.delegate = self
        }
    }
    
    private let analytics = PhotoEditAnalytics()
    
    private lazy var filterView = self.prepareFilterView()
    
    private lazy var adjustmentManager: AdjustmentManager = {
        let types = AdjustmentViewType.allCases.flatMap { $0.adjustmentTypes }
        return AdjustmentManager(types: types)
    }()
    
    private var tempAdjustmentValues = [AdjustmentParameterValue]()
    private var tempHSLValue: HSVMultibandColor?
    
    private var filterManager = FilterManager(types: FilterType.allCases)
    
    private var originalImage = UIImage()
    private var originalPreviewImage = UIImage()
    private var sourceImage = UIImage() {
        didSet {
            let originalRatio = Double(sourceImage.size.width / sourceImage.size.height)
            ratios = AdjustRatio.allValues(originalRatio: originalRatio)
        }
    }
    private var tempOriginalImage = UIImage()
    private var hasChanges: Bool {
        originalPreviewImage != sourceImage
    }

    //Adjust view
    private var cropController: CropViewController?
    private var cropResult: Mantis.CropResult?
    private var ratios = [AdjustRatio]()
    private var ratio: AdjustRatio?
    private var adjustView: AdjustView?
    
    var presentedCallback: VoidHandler?
    var finishedEditing: PhotoEditCompletionHandler?
    
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setInitialState()
        presentedCallback?()
        analytics.trackScreen(.photoEditFilters)
    }
    
    func saveImageComplete(saveAsCopy: Bool) {
        trackChanges(saveAsCopy: saveAsCopy)
    }

    private func setInitialState() {
        uiManager.showInitialState()
        uiManager.image = sourceImage
        uiManager.navBarView.state = hasChanges ? .edit : .initial
    }
    
    private func prepareFilterView() -> PreparedFiltersView {
        let previewImage = originalPreviewImage.resizedImage(to: CGSize(width: 100, height: 100)) ?? originalPreviewImage
        return PreparedFiltersView.with(previewImage: previewImage, manager: filterManager, delegate: self)
    }
    
    private func showMoreActionsMenu() {
        let controller = SelectionMenuController.photoEditMenu { [weak self] selectedOption in
            guard let self = self, let selectedOption = selectedOption else {
                return
            }
            
            switch selectedOption {
            case .saveAsCopy:
                self.saveAsCopy()
                
            case .resetToOriginal:
                self.resetToOriginal()
                self.analytics.trackClickEvent(.resetToOriginal)
            default:
                //cancelled
                break
            }
        }
        present(controller, animated: false)
    }
    
    private func saveAsCopy() {
        analytics.trackClickEvent(.saveAsCopy)
        
        let popup = PhotoEditViewFactory.alert(for: .saveAsCopy) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.prepareOriginalImage { [weak self] image in
                guard let self = self else {
                    return
                }
                
                self.finishedEditing?(self, .savedAs(image: image))
            }
        }
        present(popup, animated: true)
    }
    
    private func saveWithModifyOriginal() {
        analytics.trackClickEvent(.save)
        
        let popup = PhotoEditViewFactory.alert(for: .modify) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.prepareOriginalImage { [weak self] image in
                guard let self = self else {
                    return
                }
                
                self.finishedEditing?(self, .saved(image: image))
            }
        }
        present(popup, animated: true)
    }
    
    private func prepareOriginalImage(completion: @escaping ValueHandler<UIImage>) {
        filterManager.saveHisory()
        
        adjustmentManager.applyAll(sourceImage: self.originalImage) { [weak self] adjustedImage in
            guard let self = self else {
                return
            }
            
            guard let filteredImage = self.filterManager.applyAll(image: adjustedImage) else {
                return
            }
            
            var resultImage = filteredImage
            if
                let cropInfo = self.cropResult?.cropInfo,
                let croppedImage = Mantis.getCroppedImage(byCropInfo: cropInfo, andImage: filteredImage)
            {
                resultImage = croppedImage
            }
            
            completion(resultImage)
        }
    }
    
    private func resetToOriginal() {
        adjustmentManager.resetValues()
        sourceImage = originalPreviewImage
        tempOriginalImage = originalPreviewImage
        setInitialState()
        filterView.resetToOriginal()
        filterManager.resetToOriginal()
        cropResult = nil
        ratio = nil
    }
    
    private func trackChanges(saveAsCopy: Bool) {
        let action: GAEventAction = saveAsCopy ? .saveAsCopy : .save
        
        let parameters = adjustmentManager.adjustments.flatMap { $0.parameters.filter { $0.currentValue != $0.defaultValue } }.map { $0.type }
        analytics.trackAdjustments(parameters, action: action)
        
        if let appliedFilter = filterManager.lastApplied {
            analytics.trackFilter(appliedFilter.type, action: action)
        }
        
        if let transformation = cropResult?.transformation {
            analytics.trackAdjustChanges(transformation, action: action)
        }
    }
}

//MARK: - AdjustmentsViewDelegate

extension PhotoEditViewController: AdjustmentsViewDelegate {
    
    func showHSLFilter() {
        //cancel unsaved color adjustments
        adjustmentManager.updateValues(tempAdjustmentValues)
        needShowAdjustmentView(for: .hsl)
    }
    
    func didChangeAdjustments(_ adjustments: [AdjustmentParameterValue]) {
        adjustmentManager.applyOnValueDidChange(adjustmentValues: adjustments, sourceImage: tempOriginalImage) { [weak self] outputImage in
            guard let self = self else {
                return
            }
            
            self.uiManager.image = outputImage
        }
    }
    
    func didChangeHSLColor(_ color: HSVMultibandColor) {
        adjustmentManager.applyOnHSLColorDidChange(value: color, sourceImage: tempOriginalImage) { [weak self] outputImage in
            guard let self = self else {
                return
            }
            
            self.uiManager.image = outputImage
        }
    }
}

//MARK: - FilterChangesBarDelegate

extension PhotoEditViewController: PhotoEditChangesBarDelegate {
    func cancelChanges() {
        guard let currentPhotoEditViewType = uiManager.currentPhotoEditViewType else {
            assertionFailure()
            return
        }
        
        switch currentPhotoEditViewType {
        case .adjustmentView(let type):
            adjustmentManager.updateValues(tempAdjustmentValues)
            tempAdjustmentValues = []
            
            switch type {
            case .hsl:
                needShowAdjustmentView(for: .color)
                uiManager.image = sourceImage
                
                if let color = tempHSLValue {
                    adjustmentManager.updateHSLValue(color)
                    tempHSLValue = nil
                }
            default:
                setInitialState()
            }
            
        case .filterView(let type):
            setInitialState()
            let value = filterManager.filters.first(where: { $0.type == type })?.parameter.maxValue ?? 1
            didChangeFilter(type, newValue: value)
        }
    }
    
    func applyChanges() {
        if let image = uiManager.image {
            sourceImage = image
        }
        
        guard let currentPhotoEditViewType = uiManager.currentPhotoEditViewType else {
            setInitialState()
            return
        }

        switch currentPhotoEditViewType {
        case .adjustmentView(let type):
            tempAdjustmentValues = []
            
            switch type {
            case .adjust:
                cropController?.crop()
            case .hsl:
                needShowAdjustmentView(for: .color)
            default:
                setInitialState()
            }
            
        case .filterView(_):
            setInitialState()
        }
    }
}

//MARK: - PhotoEditNavbarDelegate

extension PhotoEditViewController: PhotoEditNavbarDelegate {
    func onClose() {
        analytics.trackClickEvent(.cancel)
        
        if !hasChanges {
            finishedEditing?(self, .canceled)
            return
        }
        
        let popup = PhotoEditViewFactory.alert(for: .close, leftButtonHandler: { [weak self] in
            self?.analytics.trackClickEvent(.keepEditing)
        }, rightButtonHandler: { [weak self] in
            guard let self = self else {
                return
            }
            self.analytics.trackClickEvent(.discard)
            self.finishedEditing?(self, .canceled)
        })
        present(popup, animated: true)
    }
    
    func onSavePhoto() {
        saveWithModifyOriginal()
    }
    
    func onMoreActions() {
        showMoreActionsMenu()
    }
    
    func onSharePhoto() {}
}

//MARK: - PhotoEditViewUIManagerDelegate

extension PhotoEditViewController: PhotoEditViewUIManagerDelegate {
    
    func needShowAdjustmentView(for type: AdjustmentViewType) {
        guard type != .adjust else {
            let view = AdjustView.with(selectedRatio: ratio, ratios: ratios, transformation: cropResult?.transformation, delegate: self)
            var config = Mantis.Config()
            config.showRotationDial = false
            if let transformation = cropResult?.transformation {
                config.presetTransformationType = .presetInfo(info: transformation)
            }
            let controller = Mantis.cropCustomizableViewController(image: self.tempOriginalImage, config: config, cropToolbar: view)
            controller.delegate = self
            
            let changesBar = PhotoEditViewFactory.generateChangesBar(with: type.title, delegate: self)
            uiManager.showView(type: .adjustmentView(type), view: controller.view, changesBar: changesBar)
            
            if let ratio = ratio {
                controller.setRatio(ratio.value)
            }
            
            cropController = controller
            adjustView = view
            return
        }
        
        guard let view = PhotoEditViewFactory.generateView(for: type, adjustments: adjustmentManager.adjustments, delegate: self) else {
            return
        }
        
        if type == .hsl, let adjustment = adjustmentManager.adjustments.first(where: { $0.type == .hsl }) {
            tempHSLValue = adjustment.hslColorParameter?.currentValue
        }
        
        tempAdjustmentValues = adjustmentManager.adjustmentValues
        
        let changesBar = PhotoEditViewFactory.generateChangesBar(with: type.title, delegate: self)
        uiManager.showView(type: .adjustmentView(type), view: view, changesBar: changesBar)
    }
    
    func filtersView() -> UIView {
        return filterView
    }
    
    func didSwitchTabBarItem(_ item: PhotoEditTabbarItemType) {
        switch item {
        case .filters:
            analytics.trackScreen(.photoEditFilters)
            
        case .adjustments:
            filterManager.saveHisory()
            filterManager.resetLastApplied()
            analytics.trackScreen(.photoEditAdjustments)
        }
        
        tempOriginalImage = sourceImage
    }
}

//MARK: - CropViewControllerDelegate

extension PhotoEditViewController: CropViewControllerDelegate {
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) { }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        cropController = nil
        adjustView = nil
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropResult: CropResult) {
        guard let cropped = cropResult.croppedImage else {
            return
        }
        
        ratio = adjustView?.selectedRatio
        self.cropResult = cropResult
        sourceImage = cropped
        tempOriginalImage = cropped
        uiManager.image = cropped
        cropController = nil
        adjustView = nil
        setInitialState()
    }
}

//MARK: - PreparedFiltersViewDelegate

extension PhotoEditViewController: PreparedFiltersViewDelegate {

    func didSelectOriginal() {
        sourceImage = originalPreviewImage
        setInitialState()
        filterManager.resetToOriginal()
    }
    
    func didSelectFilter(_ type: FilterType) {
        let value = filterManager.filters.first(where: { $0.type == type })?.parameter.currentValue ?? 1
        didChangeFilter(type, newValue: value)
        uiManager.navBarView.state = .edit
        applyChanges()
    }
    
    func needOpenFilterSlider(for type: FilterType) {
        guard let filter = filterManager.filters.first(where: { $0.type == type}) else {
            return
        }
        
        let filterView = PhotoEditViewFactory.generateFilterView(filter, delegate: self)
        let changesBar = PhotoEditViewFactory.generateChangesBar(with: type.title, delegate: self)
        uiManager.showView(type: .filterView(type), view: filterView, changesBar: changesBar)
    }
}

//MARK: - PreparedFilterSliderViewDelegate

extension PhotoEditViewController: PreparedFilterSliderViewDelegate {
    func didChangeFilter(_ filterType: FilterType, newValue: Float) {
        let filteredImage = filterManager.filter(image: tempOriginalImage, type: filterType, intensity: newValue)
        uiManager.image = filteredImage
    }
}

//MARK: - AdjustViewDelegate

extension PhotoEditViewController: AdjustViewDelegate {
    func didShowRatioMenu(_ view: AdjustView, selectedRatio: AdjustRatio) {
        guard let selectedIndex = ratios.firstIndex(where: { $0.name == selectedRatio.name }) else {
            return
        }
        
        let controller = SelectionMenuController.with(style: .checkmark, items: ratios.map { $0.name }, selectedIndex: selectedIndex) { [weak self] index in
            guard let self = self, let index = index else {
                return
            }
            
            let newRatio = self.ratios[index]
            view.updateRatio(newRatio)
            self.cropController?.setRatio(newRatio.value)
        }
        present(controller, animated: false)
    }
    
    func didChangeAngle(_ value: Float) {
        cropController?.manualRotate(rotateAngle: CGFloat(value))
    }
}

private class PhotoEditAnalytics {
    
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
    
    func trackScreen(_ screen: AnalyticsAppScreens) {
        analyticsService.logScreen(screen: screen)
        analyticsService.trackDimentionsEveryClickGA(screen: screen)
    }
    
    func trackFilter(_ type: FilterType, action: GAEventAction) {
        analyticsService.trackPhotoEditEvent(category: .filters, eventAction: action, eventLabel: .photoEdit(.saveFilter(type.title)))
    }
    
    func trackAdjustments(_ parameters: [AdjustmentParameterType], action: GAEventAction) {
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
    
    func trackAdjustChanges(_ transformation: Transformation, action: GAEventAction) {
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
        }
    }
}

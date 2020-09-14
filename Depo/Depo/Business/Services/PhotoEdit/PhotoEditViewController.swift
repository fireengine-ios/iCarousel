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
    
    private lazy var adjustManager = PhotoEditAdjustManager(delegate: self)
    
    private var lastColorAdjustmentValues = [AdjustmentParameterValue]() //currently using for transaction from HSL back https://jira.turkcell.com.tr/browse/COF-269
    
    private var tempAdjustmentValues = [AdjustmentParameterValue]()
    private var tempHSLValue: HSVMultibandColor?
    
    private var filterManager = FilterManager(types: FilterType.allCases)
    
    private var originalImage = UIImage()
    private var originalPreviewImage = UIImage() {
        didSet {
            let originalRatio = Double(originalPreviewImage.size.width / originalPreviewImage.size.height)
            adjustManager.setupRatios(original: originalRatio)
        }
    }
    private var sourceImage = UIImage()
    private var tempOriginalImage = UIImage()
    private var hasChanges: Bool {
        originalPreviewImage != sourceImage
    }
    
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
        uiManager.image = sourceImage
        uiManager.showInitialState()
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
            self?.prepareOriginalImage { [weak self] image in
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
            self?.prepareOriginalImage { [weak self] image in
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
        
        let croppedImage = adjustManager.getCroppedImage(for: originalImage)
        let filteredImage = filterManager.applyAll(image: croppedImage)
        adjustmentManager.applyAll(sourceImage: filteredImage, onFinished: completion)
    }
    
    private func prepareAdjustImage(sourceImage: UIImage, completion: @escaping ValueHandler<UIImage>) {
        let filteredImage = filterManager.applyAll(image: sourceImage)
        adjustmentManager.applyAll(sourceImage: filteredImage, onFinished: completion)
    }
    
    private func resetToOriginal() {
        adjustmentManager.resetValues()
        sourceImage = originalPreviewImage
        tempOriginalImage = originalPreviewImage
        setInitialState()
        filterView.resetToOriginal()
        filterManager.resetToOriginal()
        adjustManager.reset()
    }
    
    private func trackChanges(saveAsCopy: Bool) {
        let action: GAEventAction = saveAsCopy ? .saveAsCopy : .save
        
        let parameters = adjustmentManager.adjustments.flatMap { $0.parameters.filter { $0.currentValue != $0.defaultValue } }.map { $0.type }
        analytics.trackAdjustments(parameters, action: action)
        
        if let appliedFilter = filterManager.lastApplied {
            analytics.trackFilter(appliedFilter.type, action: action)
        }
        
        if let transformation = adjustManager.transformation {
            analytics.trackAdjustChanges(transformation, action: action)
        }
    }
    
    private func getCurrentColorValues() -> [AdjustmentParameterValue] {
        return adjustmentManager.adjustmentValues.filter{ switch $0.type {
        case .temperature, .tint, .saturation, .gamma:
            return true
        default:
            return false
            } }
    }
}

//MARK: - AdjustmentsViewDelegate

extension PhotoEditViewController: AdjustmentsViewDelegate {

    func showHSLFilter() {
        lastColorAdjustmentValues = getCurrentColorValues()
        adjustmentManager.updateValues(tempAdjustmentValues)//initital values
        needShowAdjustmentView(for: .hsl)
    }
    
    func didChangeAdjustments(_ adjustments: [AdjustmentParameterValue]) {
        adjustmentManager.applyOnValueDidChange(adjustmentValues: adjustments, sourceImage: tempOriginalImage) { [weak self] outputImage in
            self?.uiManager.image = outputImage
        }
    }
    
    func didChangeHSLColor(_ color: HSVMultibandColor) {
        adjustmentManager.applyOnHSLColorDidChange(value: color, sourceImage: tempOriginalImage) { [weak self] outputImage in
            self?.uiManager.image = outputImage
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
            case .adjust:
                lastColorAdjustmentValues = []
                adjustManager.cancelLastChanges()
                setInitialState()
            case .hsl:
                if !lastColorAdjustmentValues.isEmpty {
                    adjustmentManager.updateValues(lastColorAdjustmentValues)
                }
                adjustmentManager.applyOnValueDidChange(adjustmentValues: lastColorAdjustmentValues, sourceImage: tempOriginalImage) { [weak self] outputImage in
                    self?.lastColorAdjustmentValues = []
                    self?.uiManager.image = outputImage
                    if let color = self?.tempHSLValue {
                        self?.adjustmentManager.updateHSLValue(color)
                        self?.tempHSLValue = nil
                    }
                }
                needShowAdjustmentView(for: .color)
            case .color:
                lastColorAdjustmentValues.removeAll()
                adjustmentManager.resetValues()
                setInitialState()
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
        func updateSourceImage(resetToInitial: Bool = true) {
            if let image = uiManager.image {
                sourceImage = image
            }
            if resetToInitial {
                setInitialState()
            }
        }
        
        guard let currentPhotoEditViewType = uiManager.currentPhotoEditViewType else {
            updateSourceImage()
            return
        }

        switch currentPhotoEditViewType {
        case .adjustmentView(let type):
            tempAdjustmentValues = []
            
            switch type {
            case .adjust:
                adjustManager.crop()
            case .hsl:
                updateSourceImage(resetToInitial: false)
                needShowAdjustmentView(for: .color)
            default:
                updateSourceImage()
            }
            
        case .filterView(_):
            updateSourceImage()
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
            prepareAdjustImage(sourceImage: self.originalPreviewImage) { [weak self] image in
                guard let self = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    let cropController = self.adjustManager.prepareCropController(for: image, sourceImage: self.originalPreviewImage)
                    let changesBar = PhotoEditViewFactory.generateChangesBar(with: type.title, delegate: self)
                    self.uiManager.showView(type: .adjustmentView(type), view: cropController.view, changesBar: changesBar)
                }
            }
            return
        }
        
        guard let view = PhotoEditViewFactory.generateView(for: type, adjustments: adjustmentManager.adjustments, delegate: self) else {
            return
        }
        
        if type == .hsl, let adjustment = adjustmentManager.adjustments.first(where: { $0.type == .hsl }) {
            tempHSLValue = adjustment.hslColorParameter?.currentValue
        }
        else if type == .color {
            lastColorAdjustmentValues.removeAll()
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
//            filterManager.saveHisory()
//            filterManager.resetLastApplied()
            analytics.trackScreen(.photoEditAdjustments)
        }
        
        prepareTabImage(item) { [weak self] image in
            self?.tempOriginalImage = image
        }
    }
    
    private func prepareTabImage(_ item: PhotoEditTabbarItemType, onFinished: @escaping ValueHandler<UIImage>) {
        let croppedSourceImage = adjustManager.getCroppedImage(for: originalPreviewImage)
        switch item {
        case .filters:
            adjustmentManager.applyAll(sourceImage: croppedSourceImage, onFinished: onFinished)
            
        case .adjustments:
            let filteredImage = filterManager.applyAll(image: croppedSourceImage)
            onFinished(filteredImage)
        }
    }
}

//MARK: - PhotoEditAdjustManagerDelegate

extension PhotoEditViewController: PhotoEditAdjustManagerDelegate {
    
    func didCropImage(_ cropped: UIImage, croppedSourceImage: UIImage) {
        //prepare tempOriginalImage for adjustments page = crop + filters
        tempOriginalImage = filterManager.applyAll(image: croppedSourceImage)
        sourceImage = cropped
        setInitialState()
    }
    
    func needPresentRatioSelection(_ controller: SelectionMenuController) {
        present(controller, animated: false)
    }
}

//MARK: - PreparedFiltersViewDelegate

extension PhotoEditViewController: PreparedFiltersViewDelegate {

    func didSelectOriginal() {
        sourceImage = tempOriginalImage
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

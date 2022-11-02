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
    case savedAsWithStickers(imageView: OverlayStickerImageView)
}

private enum PhotoEditChangesType {
    case none
    case filter
    case adjustments
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
    
    private let analytics = PhotoEditViewController.Analytics()
    
    private lazy var filterView = self.prepareFilterView()

    private lazy var overlaySelector = OverlayStickerSelectorViewController()
    
    private lazy var adjustmentManager: AdjustmentManager = {
        let types = AdjustmentViewType.allCases.flatMap { $0.adjustmentTypes }
        let heightMultiplier = originalImage.size.height / originalPreviewImage.size.height
        let widthMultiplier = originalImage.size.width / originalPreviewImage.size.width
        let originalMultiplier = max(heightMultiplier, widthMultiplier)
        return AdjustmentManager(types: types, originalMultiplier: Float(originalMultiplier))
    }()
    
    private lazy var adjustManager = PhotoEditAdjustManager(delegate: self)
    
    private var tempAdjustmentValues = [AdjustmentViewType: [AdjustmentParameterValue]]()
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
    /// True when image is cropped, or effects/filters applied
    private var isImageEdited: Bool { originalPreviewImage != sourceImage }
    private var hasChanges: Bool { isImageEdited || uiManager.hasStickers }
    
    var presentedCallback: VoidHandler?
    var finishedEditing: PhotoEditCompletionHandler?
    
    private var firstChanges = PhotoEditChangesType.none
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setInitialState()
        presentedCallback?()
        analytics.trackFilterScreen()

        statusBarStyle = .lightContent
    }
    
    func saveImageComplete(saveAsCopy: Bool) {
        trackChanges(saveAsCopy: saveAsCopy, success: true)
    }
    
    func saveImageFailure(saveAsCopy: Bool) {
        trackChanges(saveAsCopy: saveAsCopy, success: false)
    }

    private func setInitialState() {
        uiManager.image = sourceImage
        uiManager.showInitialState()
        updateNavBarState()
    }

    private func updateNavBarState() {
        if hasChanges {
            let hasStickers = uiManager.hasStickers
            uiManager.navBarView.state = hasStickers ? .editContainsStickers : .edit
        } else {
            uiManager.navBarView.state = .initial
        }
    }
    
    private func prepareFilterView() -> PreparedFiltersView {
        let previewImage = originalPreviewImage.resizedImage(to: CGSize(width: 100, height: 100)) ?? originalPreviewImage
        return PreparedFiltersView.with(previewImage: previewImage, manager: filterManager, delegate: self)
    }
    
    private func trackChanges(saveAsCopy: Bool, success: Bool) {
        // Don't send below events for sticker-only images
        guard isImageEdited else { return }

        let action: GAEventAction = saveAsCopy ? .saveAsCopy : .save
        let netmeraAction: NetmeraEventValues.PhotoEditActionType = saveAsCopy ? .saveAsCopy : .save
        
        let parameters = adjustmentManager.adjustments.flatMap { $0.parameters.filter { $0.currentValue != $0.defaultValue } }.map { $0.type }
        if success {
            analytics.trackAdjustments(parameters, action: action, netmeraAction: netmeraAction)
        }
        
        if let appliedFilter = filterManager.lastApplied {
            if success {
                analytics.trackFilter(appliedFilter.type, action: action, netmeraAction: netmeraAction)
            }
            analytics.trackEditPhoto(success: success, type: .filter)
        }
        
        if success, let transformation = adjustManager.transformation {
            analytics.trackAdjustChanges(transformation, action: action, netmeraAction: netmeraAction)
        }
        
        if !parameters.isEmpty || adjustManager.transformation != nil {
            analytics.trackEditPhoto(success: success, type: .adjustment)
        }
    }

    private func trackSmashSave() {
        let imageView = uiManager.imageScrollView.imageView
        let label = imageView.getAttachmentInfoForAnalytics()
        let gifsToStickersIds = imageView.getAttachmentGifStickersIDs()
        analytics.trackSmashSave(attachmentsLabel: label,
                                 stickerIds: gifsToStickersIds.stickersIDs,
                                 gifIds: gifsToStickersIds.gifsIDs)
    }
}

//MARK: - PhotoEditNavbarDelegate

extension PhotoEditViewController: PhotoEditNavbarDelegate {
    func onClose() {
        analytics.trackClickEvent(.cancel)
        analytics.trackClickNetmeraEvent(.cancel)
        
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
        popup.open()
    }
    
    func onSavePhoto() {
        if uiManager.hasStickers {
            saveAsCopyWithStickers()
        } else {
            saveWithModifyOriginal()
        }
    }
    
    func onMoreActions() {
        showMoreActionsMenu()
    }
    
    func onSharePhoto() {}
    
    private func showMoreActionsMenu() {
        let items = !uiManager.hasStickers ? PhotoEditSaveMenu.allCases : [.resetToOriginal]
        let controller = SelectionMenuController.photoEditMenu(items: items) { [weak self] selectedOption in
            guard let self = self else {
                return
            }
            
            switch selectedOption {
            case .saveAsCopy:
                self.saveAsCopy()
                
            case .resetToOriginal:
                self.resetToOriginal()
                self.analytics.trackClickEvent(.resetToOriginal)
                self.analytics.trackClickNetmeraEvent(.resetToOriginal)
                self.uiManager.setHiddenBottomViews(false)
            
            default:
                self.uiManager.setHiddenBottomViews(false)
            }
        }
        
        uiManager.setHiddenBottomViews(true)
        present(controller, animated: false)
    }
    
    private func resetToOriginal() {
        firstChanges = .none
        adjustmentManager.resetValues()
        sourceImage = originalPreviewImage
        tempOriginalImage = originalPreviewImage
        tempAdjustmentValues.removeAll()
        uiManager.removeAllAttachments()
        setInitialState()
        filterView.resetToOriginal()
        filterManager.resetToOriginal()
        adjustManager.reset()
    }
    
    private func saveAsCopy() {
        analytics.trackClickEvent(.saveAsCopy)
        analytics.trackClickNetmeraEvent(.saveAsCopy)
        
        let popup = PhotoEditViewFactory.alert(for: .saveAsCopy, leftButtonHandler: { [weak self] in
            self?.uiManager.setHiddenBottomViews(false)
        }, rightButtonHandler: { [weak self] in
            self?.prepareOriginalImage { [weak self] image in
                guard let self = self else {
                    return
                }
                self.finishedEditing?(self, .savedAs(image: image))
            }
        })
        popup.open()
    }
    
    private func saveWithModifyOriginal() {
        analytics.trackClickEvent(.save)
        analytics.trackClickNetmeraEvent(.save)
        
        let popup = PhotoEditViewFactory.alert(for: .modify) { [weak self] in
            self?.prepareOriginalImage { [weak self] image in
                guard let self = self else {
                    return
                }
                
                self.finishedEditing?(self, .saved(image: image))
            }
        }
        popup.open()
    }

    private func saveAsCopyWithStickers() {
        trackSmashSave()
        if isImageEdited {
            analytics.trackClickEvent(.saveAsCopy)
            analytics.trackClickNetmeraEvent(.saveAsCopy)
        }

        let popup = PhotoEditViewFactory.alert(for: .saveAsCopy, leftButtonHandler: { [weak self] in
            self?.uiManager.setHiddenBottomViews(false)
        }, rightButtonHandler: { [weak self] in
            guard let self = self else { return }
            self.finishedEditing?(self, .savedAsWithStickers(imageView: self.uiManager.imageScrollView.imageView))
        })
        popup.open()
    }
    
    private func prepareOriginalImage(completion: @escaping ValueHandler<UIImage>) {
        filterManager.saveHisory()
        
        let croppedImage = adjustManager.getCroppedImage(for: originalImage)
        prepareEditPhoto(sourceImage: croppedImage, isOriginal: true, completion: completion)
    }
    
    private func prepareEditPhoto(sourceImage: UIImage, isOriginal: Bool, completion: @escaping ValueHandler<UIImage>) {
        switch firstChanges {
        case .none:
            completion(sourceImage)
        case .adjustments:
            adjustmentManager.applyAll(sourceImage: sourceImage, isOriginal: isOriginal) { [weak self] image in
                guard let self = self else {
                    return
                }
                
                let filteredImage = self.filterManager.applyAll(image: image)
                completion(filteredImage)
            }
        case .filter:
            let filteredImage = filterManager.applyAll(image: sourceImage)
            adjustmentManager.applyAll(sourceImage: filteredImage, onFinished: completion)
        }
    }
}

//MARK: - PhotoEditViewUIManagerDelegate

extension PhotoEditViewController: PhotoEditViewUIManagerDelegate {
    
    func needShowAdjustmentView(for type: AdjustmentViewType) {
        guard type != .adjust else {
            prepareEditPhoto(sourceImage: self.originalPreviewImage, isOriginal: false) { [weak self] image in
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

        if type == .color, let currentType = uiManager.currentPhotoEditViewType,
            case PhotoEditViewType.adjustmentView(let viewType) = currentType, viewType == .hsl {
            //we dont need to save temp values when we open color from hsl
        } else {
            tempAdjustmentValues[type] = adjustmentManager.value(for: type)
        }

        if type == .hsl, let adjustment = adjustmentManager.adjustments.first(where: { $0.type == .hsl }) {
            tempHSLValue = adjustment.hslColorParameter?.currentValue
        }
       
        let changesBar = PhotoEditViewFactory.generateChangesBar(with: type.title, delegate: self)
        uiManager.showView(type: .adjustmentView(type), view: view, changesBar: changesBar)
    }
    
    func filtersView() -> UIView {
        return filterView
    }

    func gifSelectorView() -> UIView {
        overlaySelector.overlayType = .gif
        overlaySelector.delegate = self
        return overlaySelector.view
    }

    func stickerSelectorView() -> UIView {
        overlaySelector.overlayType = .sticker
        overlaySelector.delegate = self
        return overlaySelector.view
    }
    
    func didSwitchTabBarItem(_ item: PhotoEditTabbarItemType) {
        switch item {
        case .filters:
            analytics.trackFilterScreen()
            
        case .adjustments:
//            filterManager.saveHisory()
//            filterManager.resetLastApplied()
            analytics.trackAdjustmentScreen()

        case .gif:
            analytics.trackGifScreen()

        case .sticker:
            analytics.trackStickerScreen()
        }
        
        prepareTabImage(item) { [weak self] result in
            self?.tempOriginalImage = result.tempOriginalImage
            self?.sourceImage = result.sourceImage
        }
    }

    func didRemoveAttachment() {
        updateNavBarState()
    }
    
    private func prepareTabImage(_ item: PhotoEditTabbarItemType, onFinished: @escaping ValueHandler<(tempOriginalImage: UIImage, sourceImage: UIImage)>) {
        let croppedSourceImage = adjustManager.getCroppedImage(for: originalPreviewImage)
        switch item {
        case .filters:
            if firstChanges == .adjustments {
                adjustmentManager.applyAll(sourceImage: croppedSourceImage) { [weak self] image in
                    guard let self = self else {
                        return
                    }
                    
                    let sourceImage = self.filterManager.applyAll(image: image)
                    onFinished((tempOriginalImage: image, sourceImage: sourceImage))
                }
            } else {
                let sourceImage = self.filterManager.applyAll(image: croppedSourceImage)
                onFinished((tempOriginalImage: croppedSourceImage, sourceImage: sourceImage))
            }
            
        case .adjustments:
            let filteredImage = firstChanges == .filter ? filterManager.applyAll(image: croppedSourceImage) : croppedSourceImage
            adjustmentManager.applyAll(sourceImage: filteredImage) { image in
                onFinished((tempOriginalImage: filteredImage, sourceImage: image))
            }

        case .gif, .sticker:
            //no-op
            break
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

            if let tempValues = tempAdjustmentValues[type] {
                adjustmentManager.updateValues(tempValues)
                tempAdjustmentValues.removeValue(forKey: type)
            }
            
            switch type {
            case .adjust:
                adjustManager.cancelLastChanges()
                setInitialState()
            case .hsl:
                if let hslValue = tempHSLValue {
                    adjustmentManager.updateHSLValue(hslValue)
                    tempHSLValue = nil
                }
                
                adjustmentManager.applyAll(sourceImage: tempOriginalImage) { [weak self] image in
                    self?.uiManager.image = self?.applyFilterIfNeeded(to: image)
                }
                
                needShowAdjustmentView(for: .color)
            case .color:
                adjustmentManager.applyAll(sourceImage: tempOriginalImage) { [weak self] image in
                    DispatchQueue.main.async {
                        guard let self = self else {
                            return
                        }
                        
                        self.sourceImage = self.applyFilterIfNeeded(to: image)
                        self.setInitialState()
                    }
                }
            default:
                setInitialState()
            }
            
        case .filterView(let type):
            let value = filterManager.filters.first(where: { $0.type == type })?.parameter.maxValue ?? 1
            applyFilter(type, newValue: value) { [weak self] image in
                self?.sourceImage = image
                self?.setInitialState()
            }
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
            tempAdjustmentValues.removeValue(forKey: type)
            
            switch type {
            case .adjust:
                adjustManager.crop()
            case .hsl:
                tempHSLValue = nil
                updateSourceImage(resetToInitial: false)
                needShowAdjustmentView(for: .color)
            default:
                updateSourceImage()
            }
            
            if firstChanges == .none {
                firstChanges = .adjustments
            }
            
        case .filterView(_):
            updateSourceImage()
            if firstChanges == .none {
                firstChanges = .filter
            }
        }
    }
}

//MARK: - AdjustmentsViewDelegate

extension PhotoEditViewController: AdjustmentsViewDelegate {

    func showHSLFilter() {
        needShowAdjustmentView(for: .hsl)
    }
    
    func didChangeAdjustments(_ adjustments: [AdjustmentParameterValue]) {
        adjustmentManager.applyOnValueDidChange(adjustmentValues: adjustments, sourceImage: tempOriginalImage) { [weak self] outputImage in
            self?.uiManager.image = self?.applyFilterIfNeeded(to: outputImage)
        }
    }
    
    func didChangeHSLColor(_ color: HSVMultibandColor) {
        adjustmentManager.applyOnHSLColorDidChange(value: color, sourceImage: tempOriginalImage) { [weak self] outputImage in
            self?.uiManager.image = self?.applyFilterIfNeeded(to: outputImage)
        }
    }
    
    private func applyFilterIfNeeded(to sourceImage: UIImage) -> UIImage {
        if firstChanges == .adjustments {
            return filterManager.applyAll(image: sourceImage)
        }
        return sourceImage
    }

}

extension PhotoEditViewController: OverlayStickerSelectorDelegate {
    func didSelectItem(item: SmashStickerResponse, attachmentType: AttachedEntityType) {
        showSpinner()
        uiManager.addAttachment(item: item, attachmentType: attachmentType) { [weak self] in
            self?.hideSpinner()
            self?.updateNavBarState()
        }
    }
}

//MARK: - PreparedFiltersViewDelegate

extension PhotoEditViewController: PreparedFiltersViewDelegate {

    func didSelectOriginal() {
        filterManager.resetToOriginal()
        if firstChanges == .filter {
            adjustmentManager.applyAll(sourceImage: tempOriginalImage) { [weak self] image in
                self?.sourceImage = image
                self?.setInitialState()
            }
        } else {
            sourceImage = tempOriginalImage
            setInitialState()
        }
    }
    
    func didSelectFilter(_ type: FilterType) {
        let value = filterManager.filters.first(where: { $0.type == type })?.parameter.currentValue ?? 1
        applyFilter(type, newValue: value) { [weak self] image in
            self?.uiManager.image = image
            self?.applyChanges()
        }
        updateNavBarState()
        
        if firstChanges == .none {
            firstChanges = .filter
        }
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
        applyFilter(filterType, newValue: newValue) { [weak self] image in
            self?.uiManager.image = image
        }
    }
    
    private func applyFilter(_ filterType: FilterType, newValue: Float, onFinished: @escaping ValueHandler<UIImage>) {
        guard let filteredImage = filterManager.filter(image: tempOriginalImage, type: filterType, intensity: newValue)  else {
            assertionFailure("Filters problem")
            return
        }
        
        if firstChanges == .filter {
            adjustmentManager.applyAll(sourceImage: filteredImage, onFinished: onFinished)
        } else {
            onFinished(filteredImage)
        }
    }
}

//MARK: - PhotoEditAdjustManagerDelegate

extension PhotoEditViewController: PhotoEditAdjustManagerDelegate {
    
    func didCropImage(_ cropped: UIImage, croppedSourceImage: UIImage) {
        //prepare tempOriginalImage for adjustments page = crop + filters
        if firstChanges == .filter {
            tempOriginalImage = filterManager.applyAll(image: croppedSourceImage)
        } else {
            tempOriginalImage = croppedSourceImage
        }
        sourceImage = cropped
        setInitialState()
    }
    
    func needPresentRatioSelection(_ controller: SelectionMenuController) {
        present(controller, animated: false)
    }
}

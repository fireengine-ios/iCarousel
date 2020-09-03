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
    private lazy var filterView = self.prepareFilterView()
    private var cropController: CropViewController?
    
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
    
    private var ratios = [AdjustRatio]()
    
    var presentedCallback: VoidHandler?
    var finishedEditing: PhotoEditCompletionHandler?
    
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setInitialState()
        presentedCallback?()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        uiManager.viewDidLayoutSubviews()
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
                
                default:
                    //cancelled
                    break
            }
        }
        present(controller, animated: false)
    }
    
    private func saveAsCopy() {
        let popup = PhotoEditViewFactory.alert(for: .saveAsCopy) { [weak self] in
            guard let self = self else {
                return
            }
            self.finishedEditing?(self, .savedAs(image: self.sourceImage))
        }
        present(popup, animated: true)
    }
    
    private func saveWithModifyOriginal() {
        let popup = PhotoEditViewFactory.alert(for: .modify) { [weak self] in
            guard let self = self else {
                return
            }
            self.finishedEditing?(self, .saved(image: self.sourceImage))
        }
        present(popup, animated: true)
    }
    
    private func resetToOriginal() {
        adjustmentManager.resetValues()
        sourceImage = originalPreviewImage
        tempOriginalImage = originalPreviewImage
        setInitialState()
        filterView.resetToOriginal()
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
                uiManager.navBarView.state = hasChanges ? .edit : .initial
                
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
                uiManager.navBarView.state = .edit
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
        let closeHandler: VoidHandler = { [weak self] in
            guard let self = self else {
                return
            }
            self.finishedEditing?(self, .canceled)
        }
        
        if !hasChanges {
            closeHandler()
            return
        }
        
        let popup = PhotoEditViewFactory.alert(for: .close, rightButtonHandler: closeHandler)
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
            let view = AdjustView.with(ratios: ratios, delegate: self)
            var config = Mantis.Config()
            config.showRotationDial = false
            let controller = Mantis.cropCustomizableViewController(image: self.tempOriginalImage, config: config, cropToolbar: view)
            controller.delegate = self
            
            let changesBar = PhotoEditViewFactory.generateChangesBar(with: type.title, delegate: self)
            uiManager.showView(type: .adjustmentView(type), view: controller.view, changesBar: changesBar)
            
            cropController = controller
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
        tempOriginalImage = sourceImage
    }
}

//MARK: - CropViewControllerDelegate

extension PhotoEditViewController: CropViewControllerDelegate {
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) { }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        cropController = nil
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        sourceImage = cropped
        tempOriginalImage = cropped
        uiManager.image = cropped
        cropController = nil
        setInitialState()
    }
}

//MARK: - PreparedFiltersViewDelegate

extension PhotoEditViewController: PreparedFiltersViewDelegate {

    func didSelectOriginal() {
        sourceImage = originalPreviewImage
        setInitialState()
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

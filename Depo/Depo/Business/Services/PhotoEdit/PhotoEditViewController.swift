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
    
    @IBOutlet private var uiManager: PhotoEditViewUIManager! {
        willSet {
            newValue.delegate = self
            newValue.navBarView.delegate = self
        }
    }
    private lazy var filterView = self.prepareFilterView()
    
    private var adjustmentManager: AdjustmentManager?
    private var filterManager = FilterManager(types: FilterType.allCases)
    
    private var originalImage = UIImage()
    private var sourceImage = UIImage()
    private var hasChanges: Bool {
        originalImage != sourceImage
    }
    
    var presentedCallback: VoidHandler?
    var finishedEditing: PhotoEditCompletionHandler?
    
    static func with(image: UIImage, presented: VoidHandler?, completion: PhotoEditCompletionHandler?) -> PhotoEditViewController {
        let controller = PhotoEditViewController.initFromNib()
        controller.originalImage = image
        controller.sourceImage = image
        controller.presentedCallback = presented
        controller.finishedEditing = completion
        return controller
    }
    
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
        let previewImage = originalImage.resizedImage(to: CGSize(width: 100, height: 100)) ?? originalImage
        return PreparedFiltersView.with(previewImage: previewImage, manager: filterManager, delegate: self)
    }
    
    private func showMoreActionsMenu() {
        let items = [TextConstants.photoEditSaveAsCopy, TextConstants.photoEditResetToOriginal]
        let controller = SelectionMenuController.with(style: .simple, items: items, selectedIndex: nil) { [weak self] index in
            guard let self = self else {
                return
            }
            switch index {
            case 0:
                self.finishedEditing?(self, .savedAs(image: self.sourceImage))
            case 1:
                self.resetToOriginal()
            default:
                break
            }
        }
        present(controller, animated: false)
    }
    
    private func resetToOriginal() {
        sourceImage = originalImage
        setInitialState()
        filterView.resetToOriginal()
    }
}

//MARK: - AdjustmentsViewDelegate

extension PhotoEditViewController: AdjustmentsViewDelegate {
    func roatate90Degrees() {
        //
    }
    
    func showAdjustMenu() {
        let items = ["Free", "Original", "16:9", "4:3", "3:2"]
        let controller = SelectionMenuController.with(style: .checkmark, items: items, selectedIndex: 1) { index in
            //TODO: need handle if will be use AdjustFilterView
        }
        present(controller, animated: false)
    }
    
    func showHSLFilter() {
        needShowAdjustmentView(for: .hsl)
    }
    
    func didChangeAdjustments(_ adjustments: [AdjustmentParameterValue]) {
        guard let manager = adjustmentManager else {
            return
        }
       
        manager.applyOnValueDidChange(adjustmentValues: adjustments, sourceImage: sourceImage) { [weak self] outputImage in
            guard let self = self else {
                return
            }
            
            self.uiManager.image = outputImage
        }
    }
    
    func didChangeHSLColor(_ color: HSVMultibandColor) {
        guard let manager = adjustmentManager else {
            return
        }
        
        manager.applyOnHSLColorDidChange(value: color, sourceImage: sourceImage) { [weak self] outputImage in
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
            return
        }
        
        switch currentPhotoEditViewType {
        case .adjustmentView(let type):
            switch type {
            case .hsl:
                needShowAdjustmentView(for: .color)
            default:
                setInitialState()
            }
            
        case .filterView(let type):
            setInitialState()
            let value = filterManager.filters.first(where: { $0.type == type })?.parameter.defaultValue ?? 1
            didChangeFilter(type, newValue: value)
        }
    }
    
    func applyChanges() {
        if let image = uiManager.image {
            sourceImage = image
        }
        setInitialState()
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

        let popup = PopUpController.with(title: TextConstants.photoEditCloseAlertTitle,
                                         message: TextConstants.photoEditCloseAlertMessage,
                                         image: .question,
                                         firstButtonTitle: TextConstants.photoEditCloseAlertKeepButton,
                                         secondButtonTitle: TextConstants.photoEditCloseAlertDiscardButton,
                                         secondAction: { vc in
                                            vc.close {
                                                closeHandler()
                                            }
        })
        present(popup, animated: true)
    }
    
    func onSavePhoto() {
        finishedEditing?(self, .saved(image: sourceImage))
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
            DispatchQueue.main.async {
                let controller = Mantis.cropViewController(image: self.sourceImage)
                controller.delegate = self
                self.present(controller, animated: true)
            }
            return
        }
        
        
        let manager = AdjustmentManager(types: type.adjustmentTypes)
        
        guard !manager.parameters.isEmpty,
            let view = PhotoEditViewFactory.generateView(for: type,
                                                         adjustmentParameters: manager.parameters,
                                                         adjustments: manager.adjustments,
                                                         delegate: self)
        else {
            return
        }
        
        adjustmentManager = manager
        let changesBar = PhotoEditViewFactory.generateChangesBar(with: type.title, delegate: self)
        
        uiManager.showView(type: .adjustmentView(type), view: view, changesBar: changesBar)
    }
    
    func filtersView() -> UIView {
        return filterView
    }
    
    func didSwitchTabBarItem(_ item: PhotoEditTabbarItemType) { }
}

//MARK: - CropViewControllerDelegate

extension PhotoEditViewController: CropViewControllerDelegate {
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        uiManager.image = cropped
        applyChanges()
        cropViewController.dismiss(animated: true)
    }
}

//MARK: - PreparedFiltersViewDelegate

extension PhotoEditViewController: PreparedFiltersViewDelegate {

    func didSelectOriginal() {
        sourceImage = originalImage
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
        let filteredImage = filterManager.filter(image: originalImage, type: filterType, intensity: newValue)
        uiManager.image = filteredImage
    }
}

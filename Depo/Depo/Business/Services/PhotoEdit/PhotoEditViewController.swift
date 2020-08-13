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
    
    private var adjustmentManager: AdjustmentManager?
    
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

    private func setInitialState() {
        uiManager.showInitialState()
        uiManager.setImage(sourceImage)
        uiManager.navBarView.state = hasChanges ? .edit : .initial
    }
    
    private func showMoreActionsMenu() {
        let items = ["Save as copy", "Reset to original"]
        let controller = SelectionMenuController.with(style: .simple, items: items, selectedIndex: nil) { [weak self] index in
            guard let self = self else {
                return
            }
            switch index {
            case 0:
                self.finishedEditing?(self, .savedAs(image: self.sourceImage))
            default:
                self.resetToOriginal()
            }
        }
        present(controller, animated: false)
    }
    
    private func resetToOriginal() {
        sourceImage = originalImage
        setInitialState()
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
    
    func showHLSFilter() {
        needShowFilterView(for: .hls)
    }
    
    func didChangeAdjustments(_ adjustments: [AdjustmentValue]) {
        guard let manager = adjustmentManager else {
            return
        }
       
        manager.applyOnValueDidChange(adjustmentValues: adjustments, sourceImage: sourceImage) { [weak self] outputImage in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.uiManager.setImage(outputImage)
            }
        }
    }
}

//MARK: - FilterChangesBarDelegate

extension PhotoEditViewController: FilterChangesBarDelegate {
    func cancelFilter() {
        setInitialState()
    }
    
    func applyFilter() {
        if let image = uiManager.imageView.image {
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

        let popup = PopUpController.with(title: "Discart Changes?",
                                         message: "Your changer won't be saved",
                                         image: .question,
                                         firstButtonTitle: "Keep editing",
                                         secondButtonTitle: "Discard",
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
    
    func needShowFilterView(for type: FilterViewType) {
        guard type != .adjust else {
            DispatchQueue.main.async {
                let controller = Mantis.cropViewController(image: self.sourceImage)
                controller.delegate = self
                self.present(controller, animated: true)
            }
            return
        }
        
        
        let manager = AdjustmentManager(types: type.adjustmenTypes)
        
        guard !manager.parameters.isEmpty,
            let view = PhotoFilterViewFactory.generateView(for: type, adjustmentParameters: manager.parameters, delegate: self)
        else {
            return
        }
        
        adjustmentManager = manager
        let changesBar = PhotoFilterViewFactory.generateChangesBar(for: type, delegate: self)
        
        uiManager.showFilter(type: type, view: view, changesBar: changesBar)
    }
}

extension PhotoEditViewController: CropViewControllerDelegate {
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        uiManager.setImage(cropped)
        applyFilter()
        cropViewController.dismiss(animated: true)
    }
}


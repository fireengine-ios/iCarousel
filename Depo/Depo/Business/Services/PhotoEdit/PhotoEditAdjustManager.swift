//
//  PhotoEditAdjustManager.swift
//  Depo
//
//  Created by Andrei Novikau on 9/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Mantis
import UIKit

protocol PhotoEditAdjustManagerDelegate: class {
    func didCropImage(_ cropped: UIImage, croppedSourceImage: UIImage)
    func needPresentRatioSelection(_ controller: SelectionMenuController)
}

final class PhotoEditAdjustManager {
    
    private var cropController: CropViewController?
    private(set) var transformation: Transformation?
    private(set) var cropInfo: CropInfo?
    private var ratios = [AdjustRatio]()
    private var ratio: AdjustRatio?
    private var rotateValue: Float = 0
    private var adjustView: AdjustView?

    private var sourceImage: UIImage?
    
    private weak var delegate: PhotoEditAdjustManagerDelegate?

    init(delegate: PhotoEditAdjustManagerDelegate?) {
        self.delegate = delegate
    }
    
    func reset() {
        adjustView = nil
        cropController = nil
        cropInfo = nil
        transformation = nil
        ratio = nil
        rotateValue = 0
    }
    
    func crop() {
        cropController?.crop()
    }
    
    func cancelLastChanges() {
        if let ratio = ratio {
            cropController?.setRatio(ratio.value, animated: false)
        }
        if let transformation = transformation {
            cropController?.setTransformation(transformation)
        }
        adjustView?.setup(selectedRatio: ratio, rotateValue: rotateValue)
        sourceImage = nil
    }
    
    func setupRatios(original: Double) {
        ratios = AdjustRatio.allValues(originalRatio: original)
        if ratio == nil {
            ratio = ratios.first(where: { $0.name == TextConstants.photoEditRatioOriginal })
        }
    }
    
    func prepareCropController(for image: UIImage, sourceImage: UIImage) -> CropViewController {
        self.sourceImage = sourceImage
        
        if let cropController = cropController {
            cropController.updateImage(image)
            return cropController
        }
        
        let view = AdjustView.with(selectedRatio: ratio, ratios: ratios, rotateValue: rotateValue, delegate: self)
        var config = Mantis.Config()
        config.showRotationDial = false
        if let transformation = transformation {
            config.presetTransformationType = .presetInfo(info: transformation)
        }
        
        let controller = Mantis.cropCustomizableViewController(image: image, config: config, cropToolbar: view)
        controller.delegate = self
        
        cropController = controller
        adjustView = view
        
        return controller
    }
    
    func getCroppedImage(for sourceImage: UIImage) -> UIImage {
        guard let cropInfo = cropInfo, let croppedImage = Mantis.getCroppedImage(byCropInfo: cropInfo, andImage: sourceImage) else {
            return sourceImage
        }
        return croppedImage
    }
}

//MARK: - CropViewControllerDelegate

extension PhotoEditAdjustManager: CropViewControllerDelegate {
    func cropViewControllerWillDismiss(_ cropViewController: CropViewController) { }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) { }

    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        sourceImage = nil
    }

    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropResult: CropResult) {
        guard let cropped = cropResult.croppedImage,
            let sourceImage = sourceImage,
            let croppedSourceImage = Mantis.getCroppedImage(byCropInfo: cropResult.cropInfo, andImage: sourceImage) else {
            return
        }
                
        cropController = cropViewController
        cropInfo = cropResult.cropInfo
        transformation = cropResult.transformation
        ratio = adjustView?.selectedRatio
        rotateValue = adjustView?.currentValue ?? 0
        self.sourceImage = nil
        
        delegate?.didCropImage(cropped, croppedSourceImage: croppedSourceImage)
    }
}

//MARK: - AdjustViewDelegate

extension PhotoEditAdjustManager: AdjustViewDelegate {
    func didShowRatioMenu(_ view: AdjustView, selectedRatio: AdjustRatio) {
        guard let selectedIndex = ratios.firstIndex(where: { $0.name == selectedRatio.name }) else {
            return
        }
        
        let controller = SelectionMenuController.with(style: .checkmark, items: ratios.map { $0.name }, selectedIndex: selectedIndex) { [weak self] index in
            guard let self = self, let index = index, selectedIndex != index else {
                return
            }
            
            let newRatio = self.ratios[index]
            view.updateRatio(newRatio)
            self.cropController?.setRatio(newRatio.value, animated: true)
        }

        delegate?.needPresentRatioSelection(controller)
    }
    
    func didChangeAngle(_ value: Float) {
        cropController?.manualRotate(rotateAngle: CGFloat(value))
    }
}

//
//  FilterViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum PhotoEditiComletion {
    case canceled
    case saved
    case savedAs
}

typealias PhotoEditCompletionHandler = (PhotoEditiComletion) -> Void

final class PhotoEditViewController: ViewController, NibInit {
    
    @IBOutlet private var uiManager: PhotoEditViewUIManager! {
        willSet {
            newValue.delegate = self
            newValue.navBarView.delegate = self
        }
    }
    
    var adjustmentManager: AdjustmentManager?
    
    var sourceImage = UIImage()
    
    var presentedCallback: VoidHandler?
    var finishedEditing: PhotoEditCompletionHandler?
    
    static func with(image: UIImage, presented: VoidHandler?, completion: PhotoEditCompletionHandler?) -> PhotoEditViewController {
        let controller = PhotoEditViewController.initFromNib()
        controller.sourceImage = image
        controller.presentedCallback = presented
        controller.finishedEditing = completion
        return controller
    }
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        uiManager.navBarView.delegate = self
        setInitialState()
        presentedCallback?()
    }

    private func setInitialState() {
        uiManager.showInitialState()
        uiManager.setImage(sourceImage)
    }
    
    private func showMoreActionsMenu() {
        let items = ["Save as copy", "Reset to original"]
        let controller = SelectionMenuController.with(style: .simple, items: items, selectedIndex: nil) { [weak self] index in
            debugPrint(index)
        }
        present(controller, animated: false)
    }
}

//MARK: -

extension PhotoEditViewController: FilterSliderViewDelegate {
    
    func leftButtonTapped() {
        switch uiManager.currentFilterViewType {
        case .adjust:
            let items = ["string 1", "string 2", "string 3", "string 4", "string 5"]
            let controller = SelectionMenuController.with(style: .checkmark, items: items, selectedIndex: 1) { [weak self] index in
                debugPrint(index)
            }
            present(controller, animated: false)
        case .color:
            needShowFilterView(for: .hls)
            break
        default:
            break
        }
    }
    
    func rightButtonTapped() {
        if uiManager.currentFilterViewType == .adjust {
            //rotate
        }
    }
    
    func sliderValueChanged(newValue: Float, type: AdjustmentParameterType) {
        guard let manager = adjustmentManager else {
            return
        }
        
        manager.applyOnValueDidChange(parameterType: type, value: newValue, sourceImage: sourceImage) { [weak self] image in
            self?.uiManager.setImage(image)
        }
    }
}

//MARK: - FilterChangesBarDelegate

extension PhotoEditViewController: FilterChangesBarDelegate {
    func cancelFilter() {
        setInitialState()
    }
    
    func applyFilter() {
        
    }
}

//MARK: - PhotoEditNavbarDelegate

extension PhotoEditViewController: PhotoEditNavbarDelegate {
    func onClose() {
        dismiss(animated: true, completion: nil)
    }
    
    func onSavePhoto() {
        
    }
    
    func onMoreActions() {
        showMoreActionsMenu()
    }
    
    func onSharePhoto() {}
}

//MARK: - PhotoEditViewUIManagerDelegate

extension PhotoEditViewController: PhotoEditViewUIManagerDelegate {
    
    func needShowFilterView(for type: FilterViewType) {
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

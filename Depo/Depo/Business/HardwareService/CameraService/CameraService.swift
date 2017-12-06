//
//  CameraService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 7/4/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import AVFoundation


@objc class CameraService : NSObject {
    
    typealias CameraGranted = (_ granted: Bool) -> Swift.Void
    
    typealias  Photo = (_ image: UIImage?) -> Swift.Void
    
//    private let viewController: UIViewController
    private var photoCallBack: Photo?
//    private let picker = UIImagePickerController()
    
//    init(with viewController: UIViewController) {
//        self.viewController = viewController
//        
//    }
    
    func cameraIsAvalible (cameraGranted: @escaping CameraGranted) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraGranted(true)
        case .notDetermined, .restricted: //restricted?
            AVCaptureDevice.requestAccess(for: .video, completionHandler: cameraGranted)
        case .denied:
            showAccessAlert()
        }

    }
    
    func showCamera(onViewController sourceViewViewController: UIViewController) {
        cameraIsAvalible { [weak self] accessGranted in
            guard accessGranted else {
                self?.showAccessAlert()
                return
            }
            
            self?.showPickerController(type: .camera, onViewController: sourceViewViewController)
        }
    }
    
    func showImagesPicker(onViewController sourceViewViewController: UIViewController) {
        self.showPickerController(type: .photoLibrary, onViewController: sourceViewViewController)
    }
    
    private func showPickerController(type: UIImagePickerControllerSourceType,
                                      onViewController sourceViewViewController: UIViewController) {
        guard let cameraSupportedVC = sourceViewViewController as?
            (UIImagePickerControllerDelegate & UINavigationControllerDelegate) else {
                debugPrint("this VC does not support camera picker delegate")
                return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.delegate = cameraSupportedVC
        picker.allowsEditing = true
        
        DispatchQueue.main.async(execute: {
            sourceViewViewController.present(picker,
                                             animated: true,
                                             completion: nil)
        })
    }
    
    private func showAccessAlert() {
        CustomPopUp.sharedInstance.showCustomAlert(
            withTitle: TextConstants.cameraAccessAlertTitle,
            titleAligment: .center,
            withText: TextConstants.cameraAccessAlertText, warningTextAligment: .center,
            firstButtonText: TextConstants.cameraAccessAlertNo,
            secondButtonText: TextConstants.cameraAccessAlertGoToSettings,
            isShadowViewShown: true,
            secondCustomAction: {
                CustomPopUp.sharedInstance.hideAll()
                UIApplication.shared.openSettings()
        })
    }
}

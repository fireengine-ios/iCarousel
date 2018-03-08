//
//  CameraService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 7/4/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import AVFoundation


@objc class CameraService: NSObject {
    
    typealias CameraGranted = (_ granted: Bool) -> Swift.Void
    
    typealias  Photo = (_ image: UIImage?) -> Swift.Void
    
    func cameraIsAvalible (cameraGranted: @escaping CameraGranted) {
        log.debug("CameraService cameraIsAvalible")

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
        log.debug("CameraService showCamera")

        cameraIsAvalible { [weak self] accessGranted in
            guard let `self` = self else {
                return
            }
            
            guard accessGranted else {
                self.showAccessAlert()
                return
            }
            
            self.showPickerController(type: .camera, onViewController: sourceViewViewController)
        }
    }
    
    func showImagesPicker(onViewController sourceViewViewController: UIViewController) {
        log.debug("CameraService showImagesPicker")

        self.showPickerController(type: .photoLibrary, onViewController: sourceViewViewController)
    }
    
    private func showPickerController(type: UIImagePickerControllerSourceType,
                                      onViewController sourceViewViewController: UIViewController) {
        log.debug("CameraService showPickerController")

        guard let cameraSupportedVC = sourceViewViewController as?
            (UIImagePickerControllerDelegate & UINavigationControllerDelegate) else {
                debugPrint("this VC does not support camera picker delegate")
                return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.delegate = cameraSupportedVC
        picker.allowsEditing = true
        
        DispatchQueue.main.async {
            sourceViewViewController.present(picker,
                                             animated: true,
                                             completion: nil)
        }
    }
    
    private func showAccessAlert() {
        log.debug("CameraService showAccessAlert")

        let controller = PopUpController.with(title: TextConstants.cameraAccessAlertTitle,
                                              message: TextConstants.cameraAccessAlertText,
                                              image: .none,
                                              firstButtonTitle: TextConstants.cameraAccessAlertNo,
                                              secondButtonTitle: TextConstants.cameraAccessAlertGoToSettings,
                                              secondAction: { vc in
                                                vc.close {
                                                    UIApplication.shared.openSettings()
                                                }
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
}

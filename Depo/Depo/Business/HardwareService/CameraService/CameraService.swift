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
    
    typealias CameraGranted = (_ granted: Bool) -> Void
    
    typealias  Photo = (_ image: UIImage?) -> Void
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    func cameraIsAvalible (cameraGranted: @escaping CameraGranted) {
        debugLog("CameraService cameraIsAvalible")

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraGranted(true)
        case .notDetermined, .restricted: //restricted?
            passcodeStorage.systemCallOnScreen = true
            
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                self?.passcodeStorage.systemCallOnScreen = false
                cameraGranted(granted)
            })

        case .denied:
            showAccessAlert()
        }

    }
    
    func showCamera(onViewController sourceViewViewController: UIViewController) {
        debugLog("CameraService showCamera")

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
        debugLog("CameraService showImagesPicker")

        self.showPickerController(type: .photoLibrary, onViewController: sourceViewViewController)
    }
    
    private func showPickerController(type: UIImagePickerControllerSourceType,
                                      onViewController sourceViewViewController: UIViewController) {
        debugLog("CameraService showPickerController")

        guard let cameraSupportedVC = sourceViewViewController as?
            (UIImagePickerControllerDelegate & UINavigationControllerDelegate),
            UIImagePickerController.isSourceTypeAvailable(type)
        else {
            debugPrint("this VC does not support camera picker delegate")
            return
        }

        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.delegate = cameraSupportedVC
        
        ///https://stackoverflow.com/a/40038752/5893286
        picker.allowsEditing = !Device.isIpad
        
        DispatchQueue.main.async {
            sourceViewViewController.present(picker,
                                             animated: true,
                                             completion: nil)
        }
    }
    
    private func showAccessAlert() {
        debugLog("CameraService showAccessAlert")

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
        DispatchQueue.toMain {
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
        }
    }
}

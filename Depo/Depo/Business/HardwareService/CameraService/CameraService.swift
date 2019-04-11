//
//  CameraService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 7/4/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import AVFoundation

class CameraService {
    typealias CameraGranted = (_ granted: Bool) -> Void
    typealias PhotoLibraryGranted = (_ granted: Bool, _ status: PHAuthorizationStatus) -> Void
    typealias Photo = (_ image: UIImage?) -> Void
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    func cameraIsAvailible(cameraGranted: @escaping CameraGranted) {
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
    
    func photoLibraryIsAvailable(photoLibraryGranted: @escaping PhotoLibraryGranted) {
        debugLog("Photo Library IsAvalible")
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:            
            if (Device.operationSystemVersionLessThen(10)) {
                PHPhotoLibrary.requestAuthorization({ status in
                    if status == .authorized {
                        photoLibraryGranted(true, status)
                    }
                })
            } else {
                photoLibraryGranted(true, status)
            }
        case .notDetermined, .restricted:
            passcodeStorage.systemCallOnScreen = true
            
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                self?.passcodeStorage.systemCallOnScreen = false
                if status == .authorized {
                    photoLibraryGranted(true, status)
                }
            }
        case .denied:            
            showAccessAlert()
        }
    }
    
    func showCamera(onViewController sourceViewViewController: UIViewController) {
        debugLog("CameraService showCamera")

        cameraIsAvailible { [weak self] accessGranted in
            guard let `self` = self else {
                return
            }

            if accessGranted {
                self.showPickerController(type: .camera, onViewController: sourceViewViewController)
            } else {
                self.showAccessAlert()
            }
        }
    }
    
    func showImagesPicker(onViewController sourceViewViewController: UIViewController) {
        debugLog("CameraService showImagesPicker")
        
        photoLibraryIsAvailable { [weak self] accessGranted, _ in
            guard let `self` = self else {
                return
            }
            
            if accessGranted {
                self.showPickerController(type: .photoLibrary, onViewController: sourceViewViewController)
            } else {
                self.showAccessAlert()
            }
        }
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

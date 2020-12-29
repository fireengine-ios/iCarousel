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
        let status = PHPhotoLibrary.currentAuthorizationStatus()
        
        switch status {
        case .authorized, .limited:
            photoLibraryGranted(true, status)
        case .notDetermined, .restricted:
            passcodeStorage.systemCallOnScreen = true
            
            PHPhotoLibrary.requestAuthorizationStatus { [weak self] status in
                self?.passcodeStorage.systemCallOnScreen = false
                photoLibraryGranted(status.isAccessible, status)
            }
        case .denied:            
            photoLibraryGranted(false, status)
        }
    }
    
    func showCamera<T: UIViewController>(onViewController sourceViewViewController: T) where T: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
        debugLog("CameraService showCamera")

        cameraIsAvailible { [weak self] accessGranted in
            guard let self = self else {
                return
            }

            if accessGranted {
                DispatchQueue.main.async {
                    self.showPickerController(type: .camera, onViewController: sourceViewViewController)
                }
            } else {
                self.showAccessAlert()
            }
        }
    }
    
    func showImagesPicker<T: UIViewController>(onViewController sourceViewViewController: T) where T: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
        debugLog("CameraService showImagesPicker")
        
        photoLibraryIsAvailable { [weak self] accessGranted, _ in
            guard let self = self else {
                return
            }
            
            if accessGranted {
                self.showPickerController(type: .photoLibrary, onViewController: sourceViewViewController)
            } else {
                self.showAccessAlert()
            }
        }
    }
    
    private func showPickerController<T: UIViewController>(type: UIImagePickerControllerSourceType,  onViewController sourceViewViewController: T) where T: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
        debugLog("CameraService showPickerController")
        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.delegate = sourceViewViewController
        
        ///https://stackoverflow.com/a/40038752/5893286
        picker.allowsEditing = !Device.isIpad
        
        DispatchQueue.main.async {
            sourceViewViewController.present(picker,
                                             animated: true,
                                             completion: nil)
        }
    }
    
    func showAccessAlert() {
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

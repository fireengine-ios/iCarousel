//
//  GalleryFileUploadService.swift
//  lifeBox_Business
//
//  Created by Konstantin Studilin on 23.12.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import Photos

final class GalleryFileUploadService {
    
    private lazy var cameraService = CameraService()
    
    
//    func upload<T: UIViewController>(delegate: T) where T: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
//        cameraService.showImagesPicker(onViewController: delegate)
//    }
//
    @available(iOS 14.0, *)
    func upload(delegate: PHPickerViewControllerDelegate) {
        
    }
}

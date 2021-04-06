//
//  GalleryFileUploadService.swift
//  lifeBox_Business
//
//  Created by Konstantin Studilin on 23.12.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import PhotosUI
import CoreServices


protocol GalleryFileUploadServiceDelegate: class {
    func cancelled()
    func failed(error: ErrorResponse?)
    func uploaded(items: [WrapData])
    func showSpinner()
    func hideSpinner()
}

extension GalleryFileUploadServiceDelegate {
    //optional
    func cancelled() { }
}


final class GalleryFileUploadService: NSObject {
    
    private weak var delegate: GalleryFileUploadServiceDelegate?
    private var uploadType: UploadType = .regular
    private lazy var cameraService = CameraService()
    
    
    func upload(type: UploadType, rootViewController: UIViewController, delegate: GalleryFileUploadServiceDelegate) {
        uploadType = type
        
        self.delegate = delegate
        
        cameraService.photoLibraryIsAvailable { [weak self] isAvailable, _ in
            guard let self = self else {
                return
            }
            
            guard isAvailable else {
                self.cameraService.showAccessAlert()
                self.delegate?.failed(error: nil)
                return
            }
            
            if #available(iOS 14.0, *) {
                self.uploadWithSystemPicker(rootViewController: rootViewController)
            } else {
                self.uploadWithManualPicker(rootViewController: rootViewController)
            }
        }
    }
    
    @available(iOS, deprecated: 14.0, message: "Please use uploadWithAssetPicker instead")
    private func uploadWithManualPicker(rootViewController: UIViewController) {
        DispatchQueue.main.async {
            let picker = UploadPickerController.initFromNib()
            picker.delegate = self
            let controller = UINavigationController(rootViewController: picker)
            rootViewController.present(controller, animated: true, completion: nil)
        }
    }
    
    @available(iOS 14, *)
    private func uploadWithSystemPicker(rootViewController: UIViewController) {
        let library = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: library)
        configuration.selectionLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        rootViewController.present(picker, animated: true, completion: nil)
    }
    
    private func upload(items: [WrapData]) {
        let router = RouterVC()
        let isFromAlbum = false
        
        var accountUuid = SingletonStorage.shared.accountInfo?.uuid
        var rootUUID: String = ""

        switch uploadType {
            case .regular:
                if let sharedFolderInfo = router.sharedFolderItem {
                    rootUUID = sharedFolderInfo.uuid
                }
                accountUuid = SingletonStorage.shared.accountInfo?.uuid
                
            case .sharedWithMe:
                if let sharedFolderInfo = router.sharedFolderItem {
                    accountUuid = sharedFolderInfo.accountUuid
                    rootUUID = sharedFolderInfo.uuid
                }
                
            case .sharedArea:
                if let sharedFolderInfo = router.sharedFolderItem {
                    rootUUID = sharedFolderInfo.uuid
                }
                accountUuid = SingletonStorage.shared.accountInfo?.parentAccountInfo.uuid
                
            default:
                assertionFailure()
                break
        }
        
        let controller = router.uploadSelectionList(with: items) { [weak self] selectedItems in
            guard let self = self else {
                return
            }
            UploadService.shared.uploadFileList(items: selectedItems,
                                                uploadType: self.uploadType,
                                                uploadStategy: .WithoutConflictControl,
                                                uploadTo: .ROOT,
                                                folder: rootUUID,
                                                isFavorites: false,
                                                isFromAlbum: isFromAlbum,
                                                isFromCamera: false,
                                                projectId: accountUuid,
                                                success: { [weak self] in
                self?.delegate?.uploaded(items: items)
                
            }, fail: { [weak self] error in
                self?.delegate?.failed(error: ErrorResponse.error(error))
                
            }, returnedUploadOperation: { _ in })
        }
        router.presentViewController(controller: controller)
    }
    
    private func verify(items: [WrapData]) -> String? {
        guard !items.isEmpty else {
            return TextConstants.uploadFromLifeBoxNoSelectedPhotosError
        }
        
        var filteredItems = items.filter { $0.fileSize < NumericConstants.fourGigabytes }
        guard !filteredItems.isEmpty else {
            return TextConstants.syncFourGbVideo
        }
        
        let freeDiskSpaceInBytes = Device.getFreeDiskSpaceInBytes()
        filteredItems = filteredItems.filter { $0.fileSize < freeDiskSpaceInBytes }
        guard !filteredItems.isEmpty else {
            return TextConstants.syncNotEnoughMemory
        }
        return nil
    }
    
    private func tryToUpload(assets: [PHAsset], picker: UIViewController) {
        dismiss(picker: picker) { [weak self] in
            self?.delegate?.showSpinner()
            
            self?.itemsToUpload(from: assets) { items in
                DispatchQueue.main.async {
                    self?.delegate?.hideSpinner()
                    
                    guard let self = self else {
                        return
                    }
                    
                    if let errorMessage = self.verify(items: items) {
                        self.delegate?.failed(error: ErrorResponse.string(errorMessage))
                        return
                    }
                    
                    self.upload(items: items)
                }
            }
        }
    }
    
    private func itemsToUpload(from assets: [PHAsset], completion: @escaping ValueHandler<[WrapData]>) {
        DispatchQueue.toBackground {
            let items = assets.map { asset -> WrapData in
                let assetInfo = LocalMediaStorage.default.fullInfoAboutAsset(asset: asset)
                return WrapData(info: assetInfo)
            }
            
            completion(items)
        }
    }
    
    private func dismiss(picker: UIViewController, completion: @escaping VoidHandler) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: completion)
        }
    }
}


@available(iOS 14, *)
extension GalleryFileUploadService: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty else {
            dismiss(picker: picker, completion: { [weak self] in
                self?.delegate?.cancelled()
            })
            return
        }
        
        let pickedAssets = PHAsset.getAllAssets(with: results.compactMap { $0.assetIdentifier })
        
       tryToUpload(assets: pickedAssets, picker: picker)
    }
}

extension GalleryFileUploadService: UploadPickerControllerDelegate {
    func uploadPicker(_ controller: UploadPickerController, didSelect assets: [PHAsset]) {
        tryToUpload(assets: assets, picker: controller)
    }
}

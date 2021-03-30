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
        
        itemToUpload(from: pickedAssets) { [weak self] items in
            guard let self = self else {
                return
            }
            
            if let errorMessage = self.verify(items: items) {
                self.dismiss(picker: picker) { [weak self] in
                    self?.delegate?.failed(error: ErrorResponse.string(errorMessage))
                }
                return
            }
            
            self.dismiss(picker: picker) { [weak self] in
                self?.upload(items: items)
            }
        }
        
    }
    
    private func itemToUpload(from assets: [PHAsset], completion: @escaping ValueHandler<[WrapData]>) {
        DispatchQueue.toBackground {
            let items = assets.map { asset -> WrapData in
                let assetInfo = LocalMediaStorage.default.fullInfoAboutAsset(asset: asset)
                return WrapData(info: assetInfo)
            }
            
            completion(items)
        }
    }
    
    private func dismiss(picker: PHPickerViewController, completion: @escaping VoidHandler) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: completion)
        }
    }
}

extension GalleryFileUploadService: UploadPickerControllerDelegate {
    
}

//extension GalleryFileUploadService: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true) { [weak self] in
//            self?.delegate?.cancelled()
//        }
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        itemToUpload(from: info) { [weak self] item in
//            guard let self = self else {
//                return
//            }
//
//            guard let item = item else {
//                self.dismiss(picker: picker) { [weak self] in
//                    self?.delegate?.failed(error: nil)
//                }
//                return
//            }
//
//            if let errorMessage = self.verify(items: [item]) {
//                self.dismiss(picker: picker) { [weak self] in
//                    self?.delegate?.failed(error: ErrorResponse.string(errorMessage))
//                }
//                return
//            }
//
//            self.dismiss(picker: picker) { [weak self] in
//
//                self?.upload(items: [item])
//            }
//        }
//    }
//
//    private func dismiss(picker: UIImagePickerController, completion: @escaping VoidHandler) {
//        DispatchQueue.main.async {
//            picker.dismiss(animated: true, completion: completion)
//        }
//    }
//
//    private func data(from info: [String: Any]) -> Data? {
//        if let imageURL = info[UIImagePickerControllerMediaURL] as? URL, let data = try? Data(contentsOf: imageURL) {
//            return data
//
//        } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
//            return UIImageJPEGRepresentation(image.imageWithFixedOrientation, 0.9)
//
//        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            return UIImageJPEGRepresentation(image.imageWithFixedOrientation, 0.9)
//        }
//
//        return nil
//    }
//
//    private func itemToUpload(from info: [String: Any], completion: @escaping ValueHandler<WrapData?>) {
//        DispatchQueue.toBackground { [weak self] in
//
//            var item: WrapData? = nil
//            if let asset = info[UIImagePickerControllerPHAsset] as? PHAsset {
//                let assetInfo = LocalMediaStorage.default.fullInfoAboutAsset(asset: asset)
//                item = WrapData(info: assetInfo)
//
//            } else if let mediaData = self?.data(from: info) {
//                let url = URL(string: UUID().uuidString, relativeTo: RouteRequests.baseUrl)
//
//                let wrapData = WrapData(imageData: mediaData, isLocal: true)
//
//                if let wrapDataName = wrapData.name {
//                    wrapData.name = wrapDataName + ".JPG"
//                }
//
//                wrapData.patchToPreview = PathForItem.remoteUrl(url)
//
//                item = wrapData
//            }
//
//            completion(item)
//        }
//    }
//}

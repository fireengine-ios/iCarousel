//
//  PhotoEditSaveService.swift
//  Depo
//
//  Created by Konstantin Studilin on 31.08.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import YYImage

final class PhotoEditSaveService {
    
    static let shared = PhotoEditSaveService()
    
    
    private let uploadService = UploadService.default
    private let coreDataStack: CoreDataStack = factory.resolve()
    private let mediaItemService = MediaItemOperationsService.shared
    private let localMediaStorage = LocalMediaStorage.default
    private let cameraService = CameraService()

    private var _overlayAnimationService: OverlayAnimationService?
    private var overlayAnimationService: OverlayAnimationService {
        if _overlayAnimationService == nil {
            _overlayAnimationService = OverlayAnimationService()
        }
        return _overlayAnimationService!
    }

    
    //MARK: - Public
    
    func save(asCopy: Bool, image: UIImage, item: WrapData, completion: @escaping ResponseHandler<WrapData>) {
        checkLibraryAccessStatus { [weak self] isAvaliable in
            guard isAvaliable else {
                self?.showAccessAlert()
                debugLog("PHOTOEDIT: PH is not allowed")
                completion(.failed(ErrorResponse.string(TextConstants.cameraAccessAlertText)))
                return
            }
            
            if asCopy {
                guard let imageData = image.jpeg(.higher) ?? UIImagePNGRepresentation(image) else {
                    debugLog("PHOTOEDIT: can't create UIImage Representation")
                    completion(.failed(ErrorResponse.string(TextConstants.cameraAccessAlertText)))
                    return
                }
                
                self?.saveAsCopy(imageData: imageData, item: item, completion: completion)
                
            } else {
                self?.save(image: image, item: item, completion: completion)
            }
        }
    }

    func saveWithStickers(originalImage: UIImage, attachments: [UIImageView], stickerImageView: UIView,
                          item: WrapData, completion: @escaping ResponseHandler<WrapData>) {
        checkLibraryAccessStatus { [weak self] isAvaliable in
            guard isAvaliable else {
                self?.showAccessAlert()
                debugLog("PHOTOEDIT: PH is not allowed")
                completion(.failed(ErrorResponse.string(TextConstants.cameraAccessAlertText)))
                return
            }

            self?.overlayStickers(resultName: item.name ?? UUID().uuidString, originalImage: originalImage,
                                  attachments: attachments, stickerImageView: stickerImageView) { [weak self] result in
                do {
                    let media = try result.get()
                    self?.saveAsCopy(mediaURL: media.url, type: media.type.toPHMediaType, item: item) { [weak self] result in
                        self?.removeImage(at: media.url)
                        completion(result)
                    }
                } catch {
                    completion(.failed(error))
                }
            }
        }
    }
    
    
    //MARK: - Save/Save as flows
    
    private func saveAsCopy(imageData: Data, item: WrapData, completion: @escaping ResponseHandler<WrapData>) {
        let tmpLocation = prepareTmpDirectoy(name: item.name ?? UUID().uuidString)
        
        do {
            try imageData.write(to: tmpLocation)
        } catch {
            completion(.failed(ErrorResponse.string("Can't write data to the tmp directoy")))
            return
        }

        saveAsCopy(mediaURL: tmpLocation, type: .image, item: item, completion: completion)
    }

    private func saveAsCopy(mediaURL: URL, type: PHAssetMediaType, item: WrapData, completion: @escaping ResponseHandler<WrapData>) {
        createLocalItem(url: mediaURL, type: type, completion: { [weak self] saveResult in
            switch saveResult {
            case .success(let localItem):
                self?.uploadItem(item: localItem, asCopy: true, completion: { uploadResult in
                    switch uploadResult {
                    case .success():
                        self?.mediaItemService.remoteItemBy(trimmedId: localItem.getTrimmedLocalID()) { remote in
                            guard let savedRemote = remote else {
                                completion(.failed(ErrorResponse.string(TextConstants.commonServiceError)))
                                assertionFailure("Can't find updated remote in the DB")
                                return
                            }
                            //to show photo immediaately
                            savedRemote.patchToPreview = localItem.patchToPreview

                            completion(.success(savedRemote))
                        }

                    case .failed(let error):
                        completion(.failed(error))
                        return
                    }
                })

            case .failed(let error):
                completion(.failed(error))
                return
            }
        })
    }
    
    private func save(image: UIImage, item: WrapData, completion: @escaping ResponseHandler<WrapData>) {
        
        debugLog("PHOTOEDIT: save")
        
        let tmpLocation = prepareTmpDirectoy(name: item.name ?? UUID().uuidString)
        
        let hasUpdatedItemCompletion = { [weak self] (result: ResponseResult<WrapData>) in
            switch result {
            case .success(let updatedItem):
                //updatedItem may be local or remote
                let isLocalExisting = updatedItem.uuid != item.uuid
                if isLocalExisting {
                    updatedItem.uuid = item.uuid
                }
                
                self?.uploadItem(item: updatedItem, asCopy: false, completion: { uploadResult in
                    switch uploadResult {
                    case .success():
                        self?.removeImage(at: tmpLocation)
                        
                        self?.mediaItemService.itemByUUID(uuid: item.uuid) { remote in
                            guard let updatedRemote = remote else {
                                debugLog("PHOTOEDIT: Can't find updated remote in the DB")
                                completion(.failed(ErrorResponse.string(TextConstants.commonServiceError)))
                                assertionFailure("Can't find updated remote in the DB")
                                return
                            }
                            //to show updated photo immediately
                            updatedRemote.patchToPreview = updatedItem.patchToPreview
                            completion(.success(updatedRemote))
                        }
                        
                    case .failed(let error):
                        debugLog("PHOTOEDIT: uploadItem error \(error.description)")
                        completion(.failed(error))
                        return
                    }
                })
                
            case .failed(let error):
                debugLog("PHOTOEDIT: didSaveLocalCompletion error \(error.description)")
                completion(.failed(error))
                return
            }
        }
    
        mediaItemService.localItemBy(trimmedId: item.getTrimmedLocalID()) { [weak self] localItem in
            guard let self = self else {
                return
            }
            
            if let asset = localItem?.asset, asset.canPerform(.content) {
                debugLog("PHOTOEDIT: replace local")
                self.replaceLocalItem(asset: asset, image: image, completion: hasUpdatedItemCompletion)
                
            } else {
                debugLog("PHOTOEDIT: localItem doesn't exist or asset can't be edited")
                
                let data = image.jpeg(.higher) ?? UIImagePNGRepresentation(image)
                
                //saving data to upload updated remote
                item.fileData = data
                hasUpdatedItemCompletion(.success(item))
                return
            }
        }
    }
    
    
    //MARK: - PH Library access
    
    private func checkLibraryAccessStatus(completion: @escaping BoolHandler) {
        cameraService.photoLibraryIsAvailable { isAvailable, _ in
            completion(isAvailable)
        }
    }
    
    private func showAccessAlert() {
        debugLog("PhotoEditSaveService showAccessAlert")
        DispatchQueue.main.async {
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
    
    
    //MARK: - Upload remote item
    
    private func uploadItem(item: WrapData, asCopy: Bool, completion: @escaping ResponseHandler<Void>) {
        uploadService.uploadFileList(items: [item],
                                     uploadType: asCopy ? .saveAs: .save,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     success: {
                                        completion(.success(()))
                                        
        }, fail: { errorResponce in
            completion(.failed(errorResponce))
        }, returnedUploadOperation: { _ in })
    }

    
    //MARK: - Save/Create local items
    
    private func createLocalItem(url: URL, type: PHAssetMediaType, completion: @escaping ResponseHandler<WrapData>) {
        localMediaStorage.saveToGallery(fileUrl: url, type: type) { [weak self] result in
            switch result {
            case .success(let placeholder):
                guard
                    let assetIdentifier = placeholder?.localIdentifier,
                    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                else {
                    assertionFailure()
                    completion(.failed(ErrorResponse.string(TextConstants.errorUnknown)))
                    return
                }
                
                self?.saveToDB(asset: asset, completion: completion)
                
            case .failed(_):
                completion(.failed(ErrorResponse.string(TextConstants.errorUnknown)))
            }
        }
    }
    
    private func saveToDB(asset: PHAsset, completion: @escaping ResponseHandler<WrapData>) {
        localMediaStorage.assetsCache.append(list: [asset])
        
        mediaItemService.append(localMediaItems: [asset]) { [weak self] in
            guard let self = self else {
                completion(.failed(ErrorResponse.string(TextConstants.errorUnknown)))
                return
            }
            
            let context = self.coreDataStack.newChildBackgroundContext
            self.mediaItemService.mediaItems(by: asset.localIdentifier, context: context, mediaItemsCallBack: { items in
                guard let savedLocalItem = items.first else {
                    assertionFailure()
                    completion(.failed(ErrorResponse.string(TextConstants.errorUnknown)))
                    return
                }
                
                let wrapData = WrapData(mediaItem: savedLocalItem, asset: asset)
                
                completion(.success(wrapData))
            })
        }
    }
    
    private func replaceLocalItem(asset: PHAsset, image: UIImage, completion: @escaping ResponseHandler<WrapData>) {
        //TODO: pass real adjustments and filters info
        localMediaStorage.replaceInGallery(asset: asset, image: image, adjustmentInfo: "Some lifebox adjustments info") { [weak self] result in
            switch result {
                case .success:
                    self?.replaceInDB(assetId: asset.localIdentifier, completion: completion)
                
                case .failed(let error):
                    debugLog("PHOTOEDIT: replaceInGallery error \(error.description)")
                    completion(.failed(ErrorResponse.error(error)))
            }
        }
    }
    
    private func replaceInDB(assetId: String, completion: @escaping ResponseHandler<WrapData>) {
        debugLog("PHOTOEDIT: replaceInDB")
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject else {
            completion(.failed(ErrorResponse.string(TextConstants.commonServiceError)))
            assertionFailure("Can't find asset to replace local item in the DB")
            return
        }
        
        localMediaStorage.assetsCache.append(list: [asset])
        
        let context = self.coreDataStack.newChildBackgroundContext
        mediaItemService.mediaItems(by: asset.localIdentifier, context: context) { [weak self] mediaItems in
            guard let existedItem = mediaItems.first else {
                assertionFailure("Can't find local item to replace in the DB")
                debugLog("PHOTOEDIT: Can't find local item to replace in the DB")
                completion(.failed(ErrorResponse.string(TextConstants.commonServiceError)))
                return
            }
            
            let updatedItem = WrapData(asset: asset)
            
            let uuid = existedItem.uuid
            existedItem.copyInfo(item: updatedItem, context: context)
            
            if let uuid = uuid {
                existedItem.uuid = uuid
                updatedItem.uuid = uuid
            }
            
            self?.coreDataStack.saveDataForContext(context: context, saveAndWait: false, savedCallBack: {
                completion(.success(updatedItem))
            })
        }
    }

    // MARK: - Stickers & Gifs
    private func overlayStickers(resultName: String, originalImage: UIImage, attachments: [UIImageView],
                                 stickerImageView: UIView, completion: @escaping (CreateOverlayStickersResult) -> Void) {
        let hasGifs = attachments.contains(where: { $0 is YYAnimatedImageView})

        if hasGifs {
            overlayAnimationService.combine(attachments: attachments, resultName: resultName, originalImage: originalImage) { [weak self] in
                // Important to free up memory when done with gif handling
                self?._overlayAnimationService = nil
                completion($0)
            }
        } else {
            guard let image = UIImage.imageWithView(view: stickerImageView) else {
                completion(.failure(.unknown))
                return
            }

            guard let imageData = image.jpeg(.higher) ?? UIImagePNGRepresentation(image) else {
                debugLog("PHOTOEDIT: can't create UIImage Representation")
                completion(.failure(.unknown))
                return
            }

            let tmpLocation = prepareTmpDirectoy(name: resultName)
            do {
                try imageData.write(to: tmpLocation)
            } catch {
                debugLog("PHOTOEDIT: Can't write image data to the tmp directoy")
                completion(.failure(.unknown))
                return
            }

            completion(.success(CreateOverlayStickersSuccessResult(url: tmpLocation, type: .image)))
        }
    }

    
    
    //MARK: - Utils
    
    private func prepareTmpDirectoy(name: String) -> URL {
        let location = Device.tmpFolderUrl(withComponent: name)
        removeImage(at: location)
        
        return location
    }
    
    private func removeImage(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error.description)
        }
    }
}

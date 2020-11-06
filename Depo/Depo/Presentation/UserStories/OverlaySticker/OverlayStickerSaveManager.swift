//
//  OverlayStickerSaveManager.swift
//  Depo
//
//  Created by Andrei Novikau on 10/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import YYImage

typealias CreateOverlayStickersResult = Result<CreateOverlayStickersSuccessResult, CreateOverlayStickerError>

final class OverlayStickerSaveManager {
    
    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    private lazy var overlayAnimationService = OverlayAnimationService()
    private lazy var uploadService = UploadService()
    
    func saveImage(resultName: String, originalImage: UIImage, attachments: [UIImageView], stickerImageView: UIView, completion: @escaping  ResponseHandler<WrapData?>) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion(.failed(CreateOverlayStickerError.deniedPhotoAccess))
            return
        }
            
        overlayStickers(resultName: resultName, originalImage: originalImage, attachments: attachments, stickerImageView: stickerImageView) { [weak self] result in
            switch result {
            case .success(let result):
                self?.saveLocalyItem(url: result.url, type: result.type, completion: { [weak self] saveResult in
                    switch saveResult {
                    case .success(let localItem):
                        self?.uploadItem(item: localItem, completion: { [weak self] uploadResult in
                            switch uploadResult {
                            case .success(let remote):
                                self?.removeImage(at: result.url)
                                remote?.patchToPreview = localItem.patchToPreview
                                completion(.success(remote))

                            case .failed(let error):
                                completion(.failed(error))
                            }
                        })
                    case .failed(let error):
                        completion(.failed(error))
                    }
                })
            case .failure(let error):
                completion(.failed(error))
            }
        }
    }
    
    private func uploadItem(item: WrapData, completion: @escaping ResponseHandler<WrapData?>) {
        var uploadOperation: UploadOperation?
        uploadService.uploadFileList(items: [item],
                                     uploadType: .syncToUse,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     success: {
                                        completion(.success(uploadOperation?.outputItem)) },
                                     fail: { errorResponce in
                                        completion(.failed(errorResponce)) },
                                     returnedUploadOperation: { operations in
                                        uploadOperation = operations?.first
        })
    }
    
    private func saveLocalyItem(url: URL, type: CreateOverlayResultType, completion: @escaping ResponseHandler<WrapData>) {
        LocalMediaStorage.default.saveToGallery(fileUrl: url, type: type.toPHMediaType) { [weak self] result in
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
        let mediaItemService = MediaItemOperationsService.shared
        LocalMediaStorage.default.assetsCache.append(list: [asset])
        mediaItemService.append(localMediaItems: [asset]) { [weak self] in
            guard let self = self else {
                return
            }
            
            let context = self.coreDataStack.newChildBackgroundContext
            mediaItemService.mediaItems(by: asset.localIdentifier, context: context, mediaItemsCallBack: { items in
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
    
    private func overlayStickers(resultName: String, originalImage: UIImage, attachments: [UIImageView], stickerImageView: UIView, completion: @escaping (CreateOverlayStickersResult) -> ()) {
        
        if attachments.contains(where: { $0 is YYAnimatedImageView}) {
            overlayAnimationService.combine(attachments: attachments, resultName: resultName, originalImage: originalImage, completion: completion)
        } else {
            
            guard let image = UIImage.imageWithView(view: stickerImageView) else {
                completion(.failure(.unknown))
                return
            }
            saveImage(image: image, fileName: resultName, completion: completion)
        }
    }
    
    private func saveImage(image: UIImage, fileName: String, completion: (CreateOverlayStickersResult) -> ()) {
        guard let data = image.jpeg(.highest) ?? UIImagePNGRepresentation(image) else {
            completion(.failure(.unknown))
            return
        }
        
        let format = ImageFormat.get(from: data) == .jpg ? ".jpg" : ".png"
        
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            completion(.failure(.unknown))
            return
        }
        
        do {
            guard let path = directory.appendingPathComponent(fileName + format) else {
                assertionFailure()
                completion(.failure(.unknown))
                return
            }
            try data.write(to: path)
            completion(.success(CreateOverlayStickersSuccessResult(url: path, type: .image)))
        } catch {
            completion(.failure(.unknown))
        }
    }
    
    private func removeImage(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error.description)
        }
    }
}

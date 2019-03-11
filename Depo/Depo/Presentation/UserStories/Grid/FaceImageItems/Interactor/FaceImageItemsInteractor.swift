//
//  FaceImageItemsInteractor.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageItemsInteractor: BaseFilesGreedInteractor {
    
    private let peopleService = PeopleService()
    private let thingsService = ThingsService()
    private let placesService = PlacesService()
    private let remoteItemsService = RemoteItemsService.init(requestSize: 999, fieldValue: FieldValue.image)
    private let accountService: AccountServicePrl = AccountService()
    private let packageService: PackageService = PackageService()
    private let iapManager = IAPManager.shared

    private var isCheckPhotos: Bool = true
    
    private var reloadItemsHandler: (() -> Void)?
    
    override func imageForNoFileImageView() -> UIImage {
        if remoteItems is PeopleItemsService {
            return UIImage(named: "peopleNoPhotos")!
        } else if remoteItems is ThingsItemsService {
            return UIImage(named: "thingsNoPhotos")!
        } else if remoteItems is PlacesItemsService {
            return UIImage(named: "locationNoPhotos")!
        }
        
        return UIImage()
    }

    override func trackScreen() {
        if remoteItems is PeopleItemsService {
            analyticsManager.logScreen(screen: .peopleFIR)
            analyticsManager.trackDimentionsEveryClickGA(screen: .peopleFIR)
            analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .recognition, eventLabel: .recognitionFace)
        } else if remoteItems is ThingsItemsService {
            analyticsManager.logScreen(screen: .thingsFIR)
            analyticsManager.trackDimentionsEveryClickGA(screen: .thingsFIR)
            analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .recognition, eventLabel: .recognitionObject)
        } else if remoteItems is PlacesItemsService {
            analyticsManager.logScreen(screen: .placesFIR)
            analyticsManager.trackDimentionsEveryClickGA(screen: .placesFIR)
            analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .recognition, eventLabel: .recognitionPlace)
        }
    }
    
    override func textForNoFileLbel() -> String {
        if remoteItems is PeopleItemsService {
            return TextConstants.faceImageNoPhotos
        } else if remoteItems is ThingsItemsService {
            return TextConstants.faceImageThingsNoPhotos
        } else if remoteItems is PlacesItemsService {
            return TextConstants.faceImagePlacesNoPhotos
        }
        
        return ""
    }
    
    override func textForNoFileButton() -> String {
        if remoteItems is PeopleItemsService {
            return TextConstants.faceImageNoPhotosButton
        } else if remoteItems is ThingsItemsService {
            return TextConstants.faceImageNoPhotosButton
        } else if remoteItems is PlacesItemsService {
            return TextConstants.faceImageNoPhotosButton
        }
        
        return ""
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        reloadItemsHandler = {
            super.reloadItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
        }
        
        getAuthorities()
    }
    
    //MARK: - Utility Methods(private)
    private func getAuthorities() {
        accountService.permissions { [weak self] result in
            switch result {
            case .success(let response):
                AuthoritySingleton.shared.refreshStatus(with: response)
                
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    DispatchQueue.main.async {
                        output.didObtainAccountPermision(isAllowed: response.hasPermissionFor(.faceRecognition))
                    }
                }
            case .failed(let error):
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    output.didFailed(errorMessage: error.description)
                }
                self?.reloadItemsHandler?()
            }
        }
    }
}

// MARK: FaceImageItemsInteractorInput

extension FaceImageItemsInteractor: FaceImageItemsInteractorInput {
    
    func loadItem(_ item: BaseDataSourceItem) {
        
        guard let item = item as? Item, let id = item.id else { return }
        
        if let item = item as? PeopleItem {
            output.startAsyncOperation()
            
            peopleService.getPeopleAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    DispatchQueue.main.async {
                        output.didLoadAlbum(album, forItem: item)
                    }
                }
                
                self?.output.asyncOperationSuccess()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        } else if let item = item as? ThingsItem {
            output.startAsyncOperation()
            
            thingsService.getThingsAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    DispatchQueue.main.async {
                        output.didLoadAlbum(album, forItem: item)
                    }
                }
                
                self?.output.asyncOperationSuccess()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        } else if let item = item as? PlacesItem {
            output.startAsyncOperation()
            
            placesService.getPlacesAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    DispatchQueue.main.async {
                        output.didLoadAlbum(album, forItem: item)
                    }
                }
                
                self?.output.asyncOperationSuccess()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        }
    }
    
    func onSaveVisibilityChanges(_ items: [PeopleItem]) {
        output.startAsyncOperation()
        
        peopleService.changePeopleVisibility(peoples: items, success: { [weak self] _ in
            if let output = self?.output as? FaceImageItemsInteractorOutput {
                DispatchQueue.main.async {
                    output.didSaveChanges(items)
                }
            }
            }, fail: { [weak self] error in
                self?.output.asyncOperationFail(errorMessage: error.description)
        })
    }
    
    func checkPhotos() {
        if (isCheckPhotos) {
            isCheckPhotos = false
            
            output.startAsyncOperation()
            
            remoteItemsService.nextItems(fileType: .image, sortBy: .date, sortOrder: .asc, success: { [weak self] items in
                if let output = self?.output as? FaceImageItemsInteractorOutput,
                    !items.isEmpty {
                    output.didShowPopUp()
                }
                
                guard let output = self?.output else { return }
                output.asyncOperationSuccess()
                }, fail: { [weak self] in
                    guard let output = self?.output else { return }
                    output.getContentWithFail(errorString: nil)//asyncOperationFail(errorMessage: nil)
                    
            })
        }
    }
    
    func changeCheckPhotosState(isCheckPhotos: Bool) {
        self.isCheckPhotos = isCheckPhotos
    }
    
    func getFeaturePacks() {
        accountService.featurePacks { [weak self] result in
            switch result {
            case .success(let response):
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    DispatchQueue.main.async {
                        output.didObtainFeaturePacks(response)
                    }
                }
            case .failed(_):
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    output.switchToTextWithoutPrice(isError: true)
                }
                
                self?.reloadItemsHandler?()
            }
        }
    }
    
    func getPriceInfo(offer: PackageModelResponse, accountType: AccountType) {
        if let output = output as? FaceImageItemsInteractorOutput, accountType == .turkcell {
            let price = packageService.getPriceInfo(for: offer, accountType: accountType)
            DispatchQueue.main.async {
                output.didObtainFeaturePrice(price)
            }
            return
        }
        
        packageService.getInfoForAppleProducts(offers: [offer], success: { [weak self] in
            if let output = self?.output as? FaceImageItemsInteractorOutput {
                let price = self?.packageService.getPriceInfo(for: offer, accountType: accountType)
                DispatchQueue.main.async {
                    if let price = price {
                        output.didObtainFeaturePrice(price)
                    } else {
                        output.switchToTextWithoutPrice(isError: false)
                        self?.reloadItemsHandler?()
                    }
                }
            }
        }, fail: { [weak self] _ in
            if let output = self?.output as? FaceImageItemsInteractorOutput {
                output.switchToTextWithoutPrice(isError: true)
            }
            
            self?.reloadItemsHandler?()
        })
    }
    
    func checkAccountType() {
        accountService.info(
            success: { [weak self] response in
                guard let response = response as? AccountInfoResponse, let accountType = response.accountType else {
                    let error = CustomErrors.serverError("An error occurred while getting account info")
                    if let output = self?.output as? FaceImageItemsInteractorOutput {
                        output.didFailed(errorMessage: error.localizedDescription)
                    }
                    self?.reloadItemsHandler?()
                    return
                }
                
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    DispatchQueue.main.async {
                        output.didObtainAccountType(accountType)
                    }
                }
            }, fail: { [weak self] errorResponse in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    output.didFailed(errorMessage: errorResponse.description)
                }
                
                self?.reloadItemsHandler?()
        })
    }
    
    func reloadFaceImageItems() {
        reloadItemsHandler?()
    }
}

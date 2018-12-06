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
    private let iapManager = IAPManager.shared

    private var isCheckPhotos: Bool = true
    
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
        let superFunc = { super.reloadItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue) }
        let group = DispatchGroup()
        
        getAuthorities(group: group)
        
        group.notify(queue: DispatchQueue.main) {
            superFunc()
        }
    }
    
    //MARK: - Utility Methids(private)
    private func getAuthorities(group: DispatchGroup) {
        group.enter()
        accountService.permissions { [weak self] result in
            switch result {
            case .success(let response):
                AuthoritySingleton.shared.refreshStatus(with: response)
                if !response.hasPermissionFor(.faceRecognition) {
                    self?.remoteItems.requestSize = NumericConstants.requestSizeForFaceImageStandartUser
                    self?.getAccountType(group: group)
                }
            case .failed(let error):
                self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
            }
            group.leave()
        }
    }
    
    private func getAccountType(group: DispatchGroup) {
        group.enter()
        accountService.info(
            success: { [weak self] response in
                guard let response = response as? AccountInfoResponse, let accountType = response.accountType else {
                    self?.output.asyncOperationFail(errorMessage: "An error occurred while getting account info")
                    return
                }
    
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    DispatchQueue.toMain {
                        output.didObtainAccountType(accountType, group: group)
                    }
                }
            }, fail: { [weak self] errorResponse in
                group.leave()
                DispatchQueue.toMain {
                    self?.output.asyncOperationFail(errorMessage: errorResponse.description)
                }
        })
    }
    
    private func getPriceInfo(for offer: PackageModelResponse, accountType: AccountType, group: DispatchGroup?) {
        let fullPrice: String
        if let iapProductId = offer.inAppPurchaseId, let product = iapManager.product(for: iapProductId) {
            let price = product.localizedPrice
            let period: String
            if #available(iOS 11.2, *) {
                switch product.subscriptionPeriod?.unit.rawValue {
                case 0:
                    period = TextConstants.packagePeriodDay
                case 1:
                    period = TextConstants.packagePeriodWeek
                case 2:
                    period = TextConstants.packagePeriodMonth
                case 3:
                    period = TextConstants.packagePeriodYear
                default:
                    period = TextConstants.packagePeriodMonth
                }
            } else {
                period = (offer.period ?? "").lowercased()
            }
            fullPrice = String(format: TextConstants.faceImageApplePrice, price, period)
        } else {
            if let price = offer.price {
                let currency = offer.currency ?? getCurrency(for: accountType)
                if let period = offer.period?.lowercased() {
                    fullPrice = String(format: TextConstants.packageApplePrice, (String(price) + " " + currency), period)
                } else {
                    fullPrice = String(price) + " " + currency
                }
            } else {
                fullPrice = TextConstants.free
            }
        }
        if let output = self.output as? FaceImageItemsInteractorOutput {
            output.didObtainFeaturePrice(fullPrice)
        } else {
            output.asyncOperationFail(errorMessage: "An error occurred while getting featue pack price")
        }
        group?.leave()
    }
    
    private func getCurrency(for accountType: AccountType) -> String {
        switch accountType {
        ///https://en.wikipedia.org/wiki/Northern_Cyprus
        case .turkcell, .cyprus:
            return "TL"
        case .ukranian:
            return "UAH"
        case .moldovian:
            return "MDL"
        case .life:
            return "BYN"
        case .all:
            return "$" /// temp
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
                    output.didLoadAlbum(album, forItem: item)
                }
                
                self?.output.asyncOperationSucces()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        } else if let item = item as? ThingsItem {
            output.startAsyncOperation()
            
            thingsService.getThingsAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    output.didLoadAlbum(album, forItem: item)
                }
                
                self?.output.asyncOperationSucces()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        } else if let item = item as? PlacesItem {
            output.startAsyncOperation()
            
            placesService.getPlacesAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    output.didLoadAlbum(album, forItem: item)
                }
                
                self?.output.asyncOperationSucces()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        }
    }
    
    func onSaveVisibilityChanges(_ items: [PeopleItem]) {
        output.startAsyncOperation()
        
        peopleService.changePeopleVisibility(peoples: items, success: { [weak self] _ in
            if let output = self?.output as? FaceImageItemsInteractorOutput {
                output.didSaveChanges(items)
            }
            
            self?.output.asyncOperationSucces()
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
                
                self?.output.asyncOperationSucces()
                }, fail: { [weak self] in
                    
                    self?.output.getContentWithFail(errorString: nil)//asyncOperationFail(errorMessage: nil)
                    
            })
        }
    }
    
    func changeCheckPhotosState(isCheckPhotos: Bool) {
        self.isCheckPhotos = isCheckPhotos
    }
    
    func getFeaturePacks(group: DispatchGroup?) {
        accountService.featurePacks { [weak self] result in
            switch result {
            case .success(let response):
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    DispatchQueue.toMain {
                        output.didObtainFeaturePacks(response)
                    }
                } else {
                    self?.output.asyncOperationFail(errorMessage: "An error occurred while getting featue packs")
                }
            case .failed(let error):
                self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
                group?.leave()
            }
        }
    }
    
    func getInfoForAppleProducts(offer: PackageModelResponse, accountType: AccountType, group: DispatchGroup?) {
        if accountType == .turkcell {
            getPriceInfo(for: offer, accountType: accountType, group: group)
            return
        }
        
        guard let offerId = offer.inAppPurchaseId else {
            output.asyncOperationFail(errorMessage: "An error occurred while getting product id from offer")
            group?.leave()
            return
        }
        iapManager.loadProducts(productIds: [offerId]) { [weak self] response in
            switch response {
            case .success(_):
                DispatchQueue.toMain {
                    self?.getPriceInfo(for: offer, accountType: accountType, group: group)
                }
            case .failed(let error):
                self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
                group?.leave()
            }
        }
    }
}

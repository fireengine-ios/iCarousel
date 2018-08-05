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
    
}

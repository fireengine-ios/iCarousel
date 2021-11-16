//
//  PhotoVideoDetailPhotoVideoDetailInteractor.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoVideoDetailInteractor: NSObject, PhotoVideoDetailInteractorInput {
    
    weak var output: PhotoVideoDetailInteractorOutput!
    
    private var array = SynchronizedArray<Item>()
    
    var albumUUID: String?
    
    var status: ItemStatus = .active
    var viewType: DetailViewType = .details
    
    private var selectedIndex: Int?
    
    var bottomBarConfig: EditingBarConfig!
    
    var moreMenuConfig = [ElementTypes]()
    
    private let peopleService = PeopleService()
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var accountService = AccountService()
    private let authorityStorage = AuthoritySingleton.shared
    private lazy var shareApiService = PrivateShareApiServiceImpl()
    private lazy var privateShareAnalytics = PrivateShareAnalytics()
    
    var setupedMoreMenuConfig: [ElementTypes] {
        return moreMenuConfig
    }
    
    var currentItemIndex: Int? {
        get {
            return selectedIndex
        }
        set {
            selectedIndex = newValue
        }
    }
    
    var allItems: [Item] {
        return array.getArray()
    }
    
    func onSelectItem(fileObject: Item, from items: [Item]) {
        array.removeAll()
        array.append(items)
        
        if fileObject.isLocalItem {
            let localId = fileObject.getLocalID()
            if let index = items.firstIndex(where: { $0.getLocalID() == localId }) {
                selectedIndex = index
            }
        } else if let index = items.firstIndex(where: { $0.uuid == fileObject.uuid }) {
            selectedIndex = index
        }
    }
    
    func onViewIsReady() {
        guard let index = selectedIndex else {
            return
        }
        
        output.onShowSelectedItem(at: index, from: array.getArray())
    }

    func bottomBarConfig(for selectedIndex: Int) -> EditingBarConfig {
        guard let selectedItem = array[selectedIndex] else {
            return EditingBarConfig(elementsConfig: [], style: .black, tintColor: nil)
        }
        let elementsConfig = ElementTypes.detailsElementsConfig(for: selectedItem, status: status, viewType: viewType)
        return EditingBarConfig(elementsConfig: elementsConfig, style: .black, tintColor: nil)
    }
    
    func deleteSelectedItem(type: ElementTypes) {
        guard let index = selectedIndex else {
            return
        }
        
        array.safeRemove(at: index)

        if index >= array.count {
            selectedIndex = array.count - 1
        }
                
        if !array.isEmpty {
            let nextIndex = index == array.count ? array.count - 1 : index
            output.updateItems(objects: array.getArray(), selectedIndex: nextIndex)
        } else {
            output.onLastRemoved()
        }
    }
    
    func replaceUploaded(_ item: WrapData) {
        if let indexToChange = array.index(where: { $0.isLocalItem && $0.getTrimmedLocalID() == item.getTrimmedLocalID() }) {
            item.isLocalItem = false
            array[indexToChange] = item
        }
    }
    
    func updateExpiredItem(_ item: WrapData) {
        if let index = allItems.firstIndex(where: { $0 == item && $0.hasExpiredPreviewUrl() }) {
            array[index] = item
        }
    }
    
    func trackVideoStart() {
        if
            let index = currentItemIndex,
            let item = allItems[safe: index],
            let metadata = item.metaData {
            analyticsService.trackEventTimely(eventCategory: .videoAnalytics, eventActions: .startVideo, eventLabel: metadata.isVideoSlideshow ? .videoStartStroy : .videoStartVideo)
        } else {
            analyticsService.trackEventTimely(eventCategory: .videoAnalytics, eventActions: .startVideo, eventLabel: .storyOrVideo)
        }
        analyticsService.trackEventTimely(eventCategory: .videoAnalytics, eventActions: .everyMinuteVideo)
    }
    
    func trackVideoStop() {
        analyticsService.stopTimelyTracking()
    }
    
    func appendItems(_ items: [Item]) {
        array.append( items)
    }
    
    func onRename(newName: String) {
        guard let index = currentItemIndex,
            let item = allItems[safe: index] else {
                return
        }
        
        guard !newName.isEmpty else {
            if let name = item.name {
                output.cancelSave(use: name)
            } else {
                output.updated()
            }
            
            return
        }
        
        guard let projectId = item.projectId else {
            return
        }
        
        shareApiService.renameItem(projectId: projectId, uuid: item.uuid, name: newName) { [weak self] result in
            switch result {
            case .success():
                item.name = newName
                self?.output.updated()
                if !item.isOwner {
                    self?.privateShareAnalytics.sharedWithMe(action: .rename, on: item)
                }
                ItemOperationManager.default.didRenameItem(item)
            case .failed(let error):
                self?.output.failedUpdate(error: error)
            }
        }
    }

    func onEditDescription(newDescription: String) {
        guard let index = currentItemIndex,
            let item = allItems[safe: index] else {
                return
        }

        guard !newDescription.isEmpty else {
            if let name = item.name {
                output.cancelSaveDescription(use: name)
            } else {
                output.updated()
            }

            return
        }

        guard let projectId = item.projectId else {
            return
        }

        shareApiService.editDescription(projectId: projectId, uuid: item.uuid, description: newDescription) { [weak self] result in
            switch result {
            case .success():
                item.metaData?.fileDescription = newDescription
                self?.output.updated()
            case .failed(let error):
                self?.output.failedUpdate(error: error)
            }
        }
    }
    
    func onValidateName(newName: String) {
        guard let index = currentItemIndex,
            let item = allItems[safe: index] else {
                return
        }
        if newName.isEmpty {
            if let name = item.name {
                output.cancelSave(use: name)
            }
        } else {
            output.didValidateNameSuccess(name: newName)
        }
    }

    func onValidateDescription(newDescription: String) {
        guard let index = currentItemIndex,
            let item = allItems[safe: index] else {
                return
        }
        if newDescription.isEmpty {
            if let description = item.name {
                output.cancelSaveDescription(use: description)
            }
        } else {
            output.didValidateDescriptionSuccess(description: newDescription)
        }
    }
    
    func getPeopleAlbum(with item: PeopleItem, id: Int64) {
        let successHandler: AlbumOperationResponse = { [weak self] album in
            DispatchQueue.main.async {
                self?.output.didLoadAlbum(album, forItem: item)
            }
        }
        
        let failHandler: FailResponse = { [weak self] error in
            DispatchQueue.main.async {
                self?.output.didFailedLoadAlbum(error: error)
            }
        }
        
        peopleService.getPeopleAlbum(id: Int(truncatingIfNeeded: id),
                                     status: item.status,
                                     success: successHandler,
                                     fail: failHandler)
    }
    
    func getFIRStatus(success: @escaping (SettingsInfoPermissionsResponse) -> (), fail: @escaping (Error) -> ()) {
        accountService.getSettingsInfoPermissions { response in
            switch response {
            case .success(let result):
                success(result)
            case .failed(let error):
                fail(error)
            }
        }
    }
    
    func enableFIR(completion: VoidHandler?) {
        accountService.changeFaceImageAndFacebookAllowed(isFaceImageAllowed: true,
                                                         isFacebookAllowed: true) { [weak self] response in
            DispatchQueue.toMain {
                switch response {
                case .success(let result):
                    NotificationCenter.default.post(name: .changeFaceImageStatus, object: self)
                    if result.isFaceImageAllowed == true {
                        DispatchQueue.main.async {
                            completion?()
                        }
                    }
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                    
                }
            }
        }
    }
    
    func getAuthority() {
        accountService.permissions { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.output.didLoadFaceRecognitionPermissionStatus(response.hasPermissionFor(.faceRecognition))
                }
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    func getPersonsOnPhoto(uuid: String, completion: VoidHandler? = nil) {
        peopleService.getPeopleForMedia(with: uuid, success: { [weak self] peopleThumbnails in
            DispatchQueue.main.async {
                self?.output.updatePeople(items: peopleThumbnails)
                    completion?()
            }
        }) { [weak self] (errorResponse) in
            DispatchQueue.main.async {
                self?.output.failedUpdate(error: errorResponse)
                self?.output.updatePeople(items: [])
                    completion?()
            }
        }
    }
    
    func createNewUrl() {
        guard let index = currentItemIndex,
              let item = allItems[safe: index],
              let projectId = item.projectId else {
            return
        }
        
        shareApiService.createDownloadUrl(projectId: projectId, uuid: item.uuid) { [weak self] result in
            switch result {
            case .success(let object):
                if let url = object.url {
                    item.tmpDownloadUrl = url
                    self?.updateItem(item)
                    self?.output.updateItem(item)
                }
            case .failed(let error):
                self?.output.failedUpdate(error: error)
            }
        }
    }
    
    private func updateItem(_ item: Item) {
        if let index = allItems.firstIndex(where: { $0 == item }) {
            array[index] = item
        }
    }
}

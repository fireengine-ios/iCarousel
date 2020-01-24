//
//  PhotoVideoDetailPhotoVideoDetailInteractor.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoVideoDetailInteractor: NSObject, PhotoVideoDetailInteractorInput {
    
    weak var output: PhotoVideoDetailInteractorOutput!
    
    private var array = [Item]()
    
    var albumUUID: String?
    
    var status: ItemStatus = .active
    var viewType: DetailViewType = .details
    
    private var selectedIndex: Int?
    
    var bottomBarConfig: EditingBarConfig!
    
    var moreMenuConfig = [ElementTypes]()
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
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
        return array
    }
    
    func onSelectItem(fileObject: Item, from items: [Item]) {
        array.removeAll()
        array.append(contentsOf: items)
        
        if fileObject.isLocalItem {
            let localId = fileObject.getLocalID()
            for (index, item) in items.enumerated() {
                if localId == item.getLocalID() {
                    selectedIndex = index
                    break
                }
            }
        } else {
            for (index, item) in items.enumerated() {
                guard let id = fileObject.id else {
                    continue
                }
                if id == item.id {
                    selectedIndex = index
                    break
                }
            }
        }
        
        
    }
    
    func onViewIsReady() {
        guard let index = selectedIndex else {
            return
        }
        
        output.onShowSelectedItem(at: index, from: array)
    }

    func bottomBarConfig(for selectedIndex: Int) -> EditingBarConfig {
        let selectedItem = array[selectedIndex]
        let elementsConfig = ElementTypes.detailsElementsConfig(for: selectedItem, status: status, viewType: viewType)
        return EditingBarConfig(elementsConfig: elementsConfig, style: .black, tintColor: nil)
    }
    
    func deleteSelectedItem(type: ElementTypes) {
        guard let index = selectedIndex else {
            return
        }
        
        let isRightSwipe = index == array.count - 1
        
        let removedObject = array[index]
            
        array.remove(at: index)
        
        if index >= array.count {
            selectedIndex = array.count - 1
        }
        
        
        switch type {
        case .hide, .unhide, .delete:
            ///its already being called from different place, we dont need to call
            break
        case .removeFromAlbum, .removeFromFaceImageAlbum:
            ItemOperationManager.default.filesRomovedFromAlbum(items: [removedObject], albumUUID: albumUUID ?? "")
        default:
            break
        }
        
        if array.isEmpty {
            /// added asyncAfter 1 sec to wait PopUpController about success deleting
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.output.goBack()
            }
        } else {
            output.updateItems(objects: array, selectedIndex: index, isRightSwipe: isRightSwipe)
        }
    }
    
    func deletePhotosFromPeopleAlbum(items: [BaseDataSourceItem], id: Int64) { }
    
    func deletePhotosFromThingsAlbum(items: [BaseDataSourceItem], id: Int64) { }
    
    func deletePhotosFromPlacesAlbum(items: [BaseDataSourceItem], uuid: String) { }
    
    func replaceUploaded(_ item: WrapData) {
        if let indexToChange = array.index(where: { $0.isLocalItem && $0.getTrimmedLocalID() == item.getTrimmedLocalID() }) {
            item.isLocalItem = false
            array[indexToChange] = item
        }
    }
    
    func trackVideoStart() {
        analyticsService.trackEventTimely(eventCategory: .videoAnalytics, eventActions: .startVideo, eventLabel: .storyOrVideo)
        analyticsService.trackEventTimely(eventCategory: .videoAnalytics, eventActions: .everyMinuteVideo)
    }
    
    func trackVideoStop() {
        analyticsService.stopTimelyTracking()
    }
}

//
//  PhotoVideoDetailPhotoVideoDetailInteractor.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoVideoDetailInteractor: NSObject, PhotoVideoDetailInteractorInput {

    weak var output: PhotoVideoDetailInteractorOutput!
    
    var array = [Item]()
    
    var albumUUID: String?
    
    var selectedIndex = 0
    
    var photoVideoBottomBarConfig: EditingBarConfig!
    var documentsBottomBarConfig: EditingBarConfig!
    
    var moreMenuConfig = [ElementTypes]()
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    var setupedMoreMenuConfig: [ElementTypes] {
        return moreMenuConfig
    }
    
    func onSelectItem(fileObject: Item, from items: [Item]) {
        array.removeAll()
        array.append(contentsOf: items)
        
        /// old logic
        //selectedIndex = array.index(of: fileObject) ?? 0
        
        /// new logic
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
        output.onShowSelectedItem(at: selectedIndex, from: array)
    }
    
    var currentItemIndex: Int {
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

    func bottomBarConfig(for selectedIndex: Int) -> EditingBarConfig {
        let selectedItem = array[selectedIndex]
        switch selectedItem.fileType {
        case .image, .video:
            var elementsConfig = photoVideoBottomBarConfig.elementsConfig
            if .video == selectedItem.fileType || selectedItem.isLocalItem {
                if let editIndex = elementsConfig.index(of: .edit) {
                    elementsConfig.remove(at: editIndex)
                }
                if let printIndex = elementsConfig.index(of: .print) {
                    elementsConfig.remove(at: printIndex)
                }
                if !elementsConfig.contains(.info) {
                    elementsConfig.append(.info)
                }
            }
            
            if .video == selectedItem.fileType && !selectedItem.isLocalItem {
                if let deleteIndex = elementsConfig.index(of: .info) {
                    elementsConfig.remove(at: deleteIndex)
                }
            }
            
            if !selectedItem.isLocalItem {
                elementsConfig.insert(.edit, at: 2)
                
                if let syncIndex = elementsConfig.index(of: .sync) {
                    elementsConfig[syncIndex] = .download
                }
                
                if let infoIndex = elementsConfig.index(of: .info) {
                    elementsConfig.remove(at: infoIndex)
                }
                if !elementsConfig.contains(.print) {
                    elementsConfig.append(.print)
                }
                
                if selectedItem.fileType == .image, !elementsConfig.contains(.smash),
                    selectedItem.name?.isPathExtensionGif() == false
                {
                    elementsConfig.append(.smash)
                }
                
                elementsConfig.append(.delete)
                
                
            } else if let syncIndex = elementsConfig.index(of: .download) {
                elementsConfig[syncIndex] = .sync
            }
            
            let langCode = Device.locale
            if let deleteIndex = elementsConfig.index(of: .print),
                langCode != "tr" {
                elementsConfig.remove(at: deleteIndex)
                
            }
            
            return EditingBarConfig(elementsConfig: elementsConfig, style: .black, tintColor: nil)
        case .application:
            return documentsBottomBarConfig
        default:
            return photoVideoBottomBarConfig
        }
        
    }
    
    func deleteSelectedItem(type: ElementTypes) {
        let isRightSwipe = selectedIndex == array.count - 1
        
        let removedObject = array[selectedIndex]
            
        array.remove(at: selectedIndex)
        
        if selectedIndex >= array.count {
            selectedIndex = array.count - 1
        }
        
        
        switch type {
        case .delete:
            ItemOperationManager.default.deleteItems(items: [removedObject])
        case .hide:
            ItemOperationManager.default.didHide(items: [removedObject])
        case .removeFromAlbum, .removeFromFaceImageAlbum:
             ItemOperationManager.default.filesRomovedFromAlbum(items: [removedObject], albumUUID: albumUUID ?? "")
        default:
            break
        }
        
        if array.isEmpty {
            /// added asyncAfter 1 sec to wait PopUpController about success deleting
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { 
                self.output.goBack()
            }
        } else {
            output.updateItems(objects: array, selectedIndex: selectedIndex, isRightSwipe: isRightSwipe)
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

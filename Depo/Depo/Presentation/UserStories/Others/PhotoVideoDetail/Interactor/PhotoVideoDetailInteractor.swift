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
    
    var setupedMoreMenuConfig: [ElementTypes] {
        return moreMenuConfig
    }
    
    func onSelectItem(fileObject: Item, from items: [Item]) {
        array.removeAll()
        array.append(contentsOf: items)
        selectedIndex = array.index(of: fileObject) ?? 0
    }
    
    func onViewIsReady() {
        output.onShowSelectedItem(at: selectedIndex, from: array)
    }
    
    func setSelectedItemIndex(selectedIndex: Int) {
        self.selectedIndex = selectedIndex
    }
    
    var currentItemIndex: Int {
        return selectedIndex
    }
    
    var allItems: [Item] {
        return array
    }

    var bottomBarConfig: EditingBarConfig {
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
                elementsConfig = elementsConfig + [.delete]
                if let syncIndex = elementsConfig.index(of: .sync) {
                    elementsConfig[syncIndex] = .download
                }
            } else {
                if let syncIndex = elementsConfig.index(of: .download) {
                    elementsConfig[syncIndex] = .sync
                }
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
        
        if (selectedIndex >= array.count) {
            selectedIndex = array.count - 1
        }
        
        if type == .delete {
            ItemOperationManager.default.deleteItems(items: [removedObject])
        }
        if type == .removeFromAlbum || type == .removeFromFaceImageAlbum {
            ItemOperationManager.default.filesRomovedFromAlbum(items: [removedObject], albumUUID: albumUUID ?? "")
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
}

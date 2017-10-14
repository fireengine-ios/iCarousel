//
//  PhotoVideoDetailPhotoVideoDetailInteractor.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoVideoDetailInteractor:NSObject, PhotoVideoDetailInteractorInput {
        
    typealias Item = WrapData

    var output: PhotoVideoDetailInteractorOutput!
    
    var array = [Item]()
    
    var selectedIndex = 0

    var bottomBarOriginalConfig: EditingBarConfig!
    
    func onSelectItem(fileObject:Item, from items:[[Item]]){
        array.removeAll()
        for ar in items{
            array.append(contentsOf: ar)
        }
        if (fileObject.fileType == FileType.image) ||
            (fileObject.fileType == FileType.video) {
            let wrapperedArray = WrapperedItemsSorting().filterByType(itemsArray: array,
                                                                      types: [FileType.video, FileType.image])
            guard let buf = wrapperedArray as? [Item] else{
                return
            }
            array = buf
        }else{
            array = [fileObject]
        }
        selectedIndex = array.index(of: fileObject)!
    }
    
    func onViewIsReady(){
        output.onShowSelectedItem(at: selectedIndex, from: array)
    }
    
    func setSelectedItemIndex(selectedIndex: Int){
        self.selectedIndex = selectedIndex
    }
    
    var currentItemIndex: Int {
        return selectedIndex
    }
    
    var allItems: [Item] {
        return array
    }
    

    var bottomBarConfig: EditingBarConfig {
        return self.bottomBarOriginalConfig
    }
    
    func deleteSelectedItem(){
        array.remove(at: selectedIndex)
        if (selectedIndex >= array.count){
            selectedIndex = array.count - 1
        }

        if (array.count == 0){
            output.goBack()
        }else{
            output.updateItems(objects: array, selectedIndex: selectedIndex)
        }
    }
}

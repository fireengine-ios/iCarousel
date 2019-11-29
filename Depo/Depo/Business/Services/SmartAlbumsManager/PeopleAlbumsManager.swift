//
//  PeopleAlbumsManager.swift
//  Depo
//
//  Created by Andrei Novikau on 11/28/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class PeopleAlbumsManager: SmartAlbumsManagerImpl {
    
    let peopleItem: PeopleItem
    private let peopleService = PeopleService()
    
    required init(peopleItem: PeopleItem) {
        self.peopleItem = peopleItem
        super.init()
    }
    
    override func requestAllItems() {
        guard let id = peopleItem.id else {
            return
        }
        let task = peopleService.getAlbumsForPeopleItemWithID(Int(truncatingIfNeeded: id), success: { [weak self] albums in
            guard let self = self else {
                return
            }
            
            self.currentItems = albums.compactMap { SliderItem(asFirAlbum: AlbumItem(remote: $0)) }
            
            DispatchQueue.main.async {
                self.delegates.invoke(invocation: { $0.loadItemsComplete(items: self.currentItems) })
            }
            
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.delegates.invoke(invocation: { $0.loadItemsFailed() })
                }
        })
        task.priority = URLSessionTask.highPriority
    }
    
    override func newStoryCreated() { }
    
    override func finishUploadFiles() { }
}

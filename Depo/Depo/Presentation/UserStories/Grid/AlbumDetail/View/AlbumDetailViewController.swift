//
//  AlbumDetailAlbumDetailViewController.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AlbumDetailViewController: BaseFilesGreedChildrenViewController {

    var album: AlbumItem?
    private lazy var dragAndDropHelper = DragAndDropHelper.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addInteraction(UIDropInteraction(delegate: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let name = album?.name {
            mainTitle = name
        }
        super.viewWillAppear(animated)
        configureNavBarActions()
    }
}

extension AlbumDetailViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: DragAndDropMediaType.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        var items: [WrapData] = []
        let myGroup = DispatchGroup()
        
        for dragItem in session.items {
            myGroup.enter()
            dragItem.itemProvider.loadObject(ofClass: DragAndDropMediaType.self, completionHandler: { object, error in
                guard error == nil else { return debugLog("Failed to load our dragged item") }
                guard let item = object as? DragAndDropMediaType else { return }
                
                if let data = item.fileData, let fileExtension = item.fileExtension, let fileType = self.dragAndDropHelper.getFileType(with: fileExtension) {
                    let wrapData = WrapData(mediaData: data, isLocal: false, fileType: fileType)
                    if let wrapDataName = wrapData.name, let dataExtension = item.fileExtension {
                        wrapData.name = wrapDataName + "." + dataExtension
                        items.append(wrapData)
                        myGroup.leave()
                    }
                }
            })
        }
        
        let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.dragAndDropUploadQueue)
        myGroup.notify(queue: dispatchQueue) {
            DragAndDropHelper.shared.uploadItems(with: items, isCustomAlbum: true, albumUUID: self.album?.uuid)
        }
    }
}

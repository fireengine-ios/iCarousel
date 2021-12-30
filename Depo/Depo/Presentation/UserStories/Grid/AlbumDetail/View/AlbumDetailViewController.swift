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
        DragAndDropHelper.shared.performDrop(with: session, itemType: DragAndDropMediaType.self, albumUUID: self.album?.uuid)
    }
}

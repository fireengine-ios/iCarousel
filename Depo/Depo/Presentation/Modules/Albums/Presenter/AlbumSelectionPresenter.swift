//
//  AlbumSelectionPresenter.swift
//  Depo
//
//  Created by Oleg on 25.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AlbumSelectionPresenter: AlbumsPresenter {
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        sortedRule = .timeUp
        dataSource.displayingType = .list
        dataSource.setPreferedCellReUseID(reUseID: nil)
        dataSource.canReselect = true
        dataSource.maxSelectionCount = 1
        dataSource.enableSelectionOnHeader = false
        dataSource.setSelectionState(selectionState: true)
    }
    
    override func onNextButton() {
        if let interact = interactor as? AlbumsInteractor {
            if (dataSource.selectedItemsArray.count > 0){
                ///!!!!!!!!!!!
                let list = Array(dataSource.selectedItemsArray)
                //let array = CoreDataStack.default.mediaItemByUUIDs(uuidList: list)
                interact.onAddPhotosToAlbum(selectedAlbumUUID: list.first!)
            }
        }
    }
    
    func photoAddedToAlbum(){
        if let view_ = view as? UIViewController{
            view_.navigationController?.popViewController(animated: true)
        }
    }

}

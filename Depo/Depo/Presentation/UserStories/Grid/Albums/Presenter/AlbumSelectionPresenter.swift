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
        dataSource.displayingType = .greed
        dataSource.setPreferedCellReUseID(reUseID: nil)
        dataSource.canReselect = true
        dataSource.canSelectionState = false
        dataSource.maxSelectionCount = 1
        dataSource.enableSelectionOnHeader = false
        dataSource.setSelectionState(selectionState: false)
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        if let interact = interactor as? AlbumsInteractor, let album = item as? AlbumItem {
            if album.readOnly == true {
                UIApplication.showErrorAlert(message: TextConstants.uploadVideoToReadOnlyAlbumError)
            } else {
                interact.onAddPhotosToAlbum(selectedAlbumUUID: album.uuid)
            }
        }
    }
    
    func photoAddedToAlbum() {
        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.snackbarMessageAddedToAlbum)
        if let view_ = view as? UIViewController {
            view_.navigationController?.popViewController(animated: true)
        }
    }

}

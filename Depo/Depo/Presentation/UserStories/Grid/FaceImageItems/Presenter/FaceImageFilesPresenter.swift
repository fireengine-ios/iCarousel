//
//  FaceImageItemsPresenter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class FaceImageItemsPresenter: BaseFilesGreedPresenter {
    
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.cellForFaceImage)
        
        dataSource.canReselect = false
    }
    
    override func selectPressed(type: MoreActionsConfig.SelectedType) {
    }
    
    override func selectModeSelected() {
    }
    
    override func onLongPressInCell() {
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        
    }

}

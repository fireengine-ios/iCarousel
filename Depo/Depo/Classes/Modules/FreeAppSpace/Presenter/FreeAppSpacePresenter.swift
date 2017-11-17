//
//  FreeAppSpaceFreeAppSpacePresenter.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FreeAppSpacePresenter: BaseFilesGreedPresenter{

    override func viewIsReady(collectionView: UICollectionView) {
        dataSource = ArrayDataSourceForCollectionView()
        super.viewIsReady(collectionView: collectionView)
        dataSource.canReselect = true
        dataSource.enableSelectionOnHeader = true
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .greed)
    }
    
    override func isArrayDataSource() -> Bool{
        return true
    }
    
    override func onNextButton() {
        if let int = interactor as? FreeAppSpaceInteractor {
            int.onDeleteSelectedItems(selectedItems: dataSource.getSelectedItems())
        }
    }
    
}


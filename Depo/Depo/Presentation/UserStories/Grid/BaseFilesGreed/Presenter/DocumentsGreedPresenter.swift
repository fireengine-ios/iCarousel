//
//  DocumentsGreedPresenter.swift
//  Depo
//
//  Created by Oleg on 21.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class DocumentsGreedPresenter: BaseFilesGreedPresenter {
    
    override func viewIsReady(collectionView: UICollectionView) {
        //interactor.viewIsReady()
        sortedRule = .lettersAZ
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.baseMultiFileCell)
        dataSource.displayingType = .list

        super.viewIsReady(collectionView: collectionView)
    }
    
    override func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: 65)
    }
    
    override func getCellSizeForGreed() -> CGSize {
        var cellWidth:CGFloat = 180
        
        if (Device.isIpad) {
            cellWidth = (view.getCollectionViewWidth() - NumericConstants.iPadGreedInset * 2  - NumericConstants.iPadGreedHorizontalSpace * (NumericConstants.numerCellInDocumentLineOnIpad - 1))/NumericConstants.numerCellInDocumentLineOnIpad
        } else {
            cellWidth = (view.getCollectionViewWidth() - NumericConstants.iPhoneGreedInset * 2  - NumericConstants.iPhoneGreedHorizontalSpace * (NumericConstants.numerCellInDocumentLineOnIphone - 1))/NumericConstants.numerCellInDocumentLineOnIphone
        }
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    override func operationFinished(withType type: ElementTypes, response: Any?) {
        let reloadTytpes: [ElementTypes] = [.delete, .addToFavorites, .removeFromFavorites, .move]
        if reloadTytpes.contains(type) {
            onReloadData()  
        }
    }
    
}

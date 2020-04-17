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
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.baseMultiFileCell)
        
        super.viewIsReady(collectionView: collectionView)
        
    }
    
    override func getCellSizeForList() -> CGSize {
        guard view != nil else {
            return .zero
        }
        return CGSize(width: view.getCollectionViewWidth(), height: 65)
    }
    
    override func getCellSizeForGreed() -> CGSize {
        var cellWidth: CGFloat = 180
        
        if (Device.isIpad) {
            cellWidth = (view.getCollectionViewWidth() - NumericConstants.iPadGreedInset * 2 - NumericConstants.iPadGreedHorizontalSpace * (NumericConstants.numerCellInDocumentLineOnIpad - 1)) / NumericConstants.numerCellInDocumentLineOnIpad
        } else {
            cellWidth = (view.getCollectionViewWidth() - NumericConstants.iPhoneGreedInset * 2 - NumericConstants.iPhoneGreedHorizontalSpace * (NumericConstants.numerCellInDocumentLineOnIphone - 1)) / NumericConstants.numerCellInDocumentLineOnIphone
        }
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}

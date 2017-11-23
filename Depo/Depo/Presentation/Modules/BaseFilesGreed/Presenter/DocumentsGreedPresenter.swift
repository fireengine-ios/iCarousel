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
        if (Device.isIpad){
            return CGSize(width: 180, height: 180)
        }else{
            let w: CGFloat = (view.getCollectionViewWidth() - NumericConstants.iPhoneGreedHorizontalSpace * 3)/NumericConstants.numerCellInDocumentLineOnIphone
            return CGSize(width: w, height: w)
        }
    }
    
}

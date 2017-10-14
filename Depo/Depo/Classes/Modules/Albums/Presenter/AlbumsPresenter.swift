//
//  AlbumsAlbumsPresenter.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumsPresenter: BaseFilesGreedPresenter {

    override func viewIsReady(collectionView: UICollectionView) {
        interactor.viewIsReady()
        sortedRule = .timeUp
        dataSource.displayingType = .list
        dataSource.setPreferedCellReUseID(reUseID: nil)
        
        super.viewIsReady(collectionView: collectionView)
    }

    override func uploadData(_ searchText: String! = nil) {
        
        interactor.nextItems(searchText, sortBy: .date, sortOrder: .asc)
    }
    
    override func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: NumericConstants.albumCellListHeight)
    }
    
    override func getCellSizeForGreed() -> CGSize {
//        if (Device.isIpad){
            return CGSize(width: 100, height: 136)
//        }
//        
//        let w = view.getCollectionViewWidth()
//        let cellW: CGFloat = (w - NumericConstants.iPhoneGreedInset * 2 - NumericConstants.iPhoneGreedHorizontalSpace * NumericConstants.numerCellInLineOnIphone)/NumericConstants.numerCellInLineOnIphone
//        return CGSize(width: cellW, height: cellW)
    }
}

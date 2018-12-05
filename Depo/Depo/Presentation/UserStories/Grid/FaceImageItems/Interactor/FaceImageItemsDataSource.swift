//
//  FaceImageItemsDataSource.swift
//  Depo
//
//  Created by Harbros 3 on 12/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class FaceImageItemsDataSource: BaseDataSourceForCollectionView {
    var price: String?
    var faceImageType: FaceImageType
    
    init(faceImageType: FaceImageType) {
        self.faceImageType = faceImageType
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if AuthoritySingleton.shared.isPremium {
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        } else {
            let premiumView = collectionView.dequeue(supplementaryView: PremiumFooterCollectionReusableView.self, kind: kind, for: indexPath)
            premiumView.configure(price: price, type: faceImageType)
            return premiumView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if AuthoritySingleton.shared.isPremium {
            return super.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: NumericConstants.premiumViewHeight)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let unwrapedObject = itemForIndexPath(indexPath: indexPath) else {
            return
        }
        
        if let peopleItem = unwrapedObject as? PeopleItem,
            peopleItem.responseObject.isDemo == true {
            delegate?.onSelectedFaceImageDemoCell(with: indexPath)
        } else {
            super.collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    // MARK: Utility methods
    func didAnimationForPremiumButton(with indexPath: IndexPath) {
        if let footerView = collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewPremiumFooter, for: indexPath) as? PremiumFooterCollectionReusableView {
            footerView.addSelectedAmination()
        }
    }
    
}


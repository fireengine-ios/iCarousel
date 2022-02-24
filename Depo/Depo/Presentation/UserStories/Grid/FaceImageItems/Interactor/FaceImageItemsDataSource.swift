//
//  FaceImageItemsDataSource.swift
//  Depo
//
//  Created by Harbros 3 on 12/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImageItemsDataSourceDelegate: AnyObject {
    func onBecomePremiumTap()
}


final class FaceImageItemsDataSource: BaseDataSourceForCollectionView {
    private static let firstPage = 1

    var price: String?
    var detailMessage: String = ""
    var faceImageType: FaceImageType
    var heightDescriptionLabel: CGFloat = 0
    var heightTitleLabel: CGFloat = 0
    var accountType: AccountType = .all
    var carouselViewHeight : CGFloat = 0
    var sumHeightMarginsForHeader : CGFloat = 0
    
    weak var premiumDelegate: FaceImageItemsDataSourceDelegate?
    
    init(faceImageType: FaceImageType, delegate: FaceImageItemsDataSourceDelegate) {
        self.faceImageType = faceImageType
        premiumDelegate = delegate
    }

    override func appendCollectionView(items: [WrapData], pageNum: Int) {
        var items = items

        let isPlaces = faceImageType == .places
        let isFirstPage = pageNum == Self.firstPage
        if isPlaces, isFirstPage, items.count > 0, AuthoritySingleton.shared.faceRecognition {
            items.insert(PlacesItem.mapPlaceholderItem(), at: 0)
        }

        super.appendCollectionView(items: items, pageNum: pageNum)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if AuthoritySingleton.shared.faceRecognition {
            if faceImageType == .people && kind == UICollectionView.elementKindSectionHeader {
                let carouselView = collectionView.dequeue(supplementaryView: CarouselPagerReusableViewController.self, kind: kind, for: indexPath)
                carouselView.maxHeight = carouselViewHeight
                carouselView.setup()
                return carouselView
            }
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        } else {
            let premiumView = collectionView.dequeue(supplementaryView: PremiumFooterCollectionReusableView.self, kind: kind, for: indexPath)
            premiumView.configureWithoutDetails(type: faceImageType, isSelectedAnimation: true)
            premiumView.delegate = self
            return premiumView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if AuthoritySingleton.shared.faceRecognition {
            return super.collectionView(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
        } else {
            var height: CGFloat = NumericConstants.premiumViewHeight + heightDescriptionLabel + heightTitleLabel
            if accountType == .turkcell {
                height += NumericConstants.plusPremiumViewHeightForTurkcell
            }
            
            return CGSize(width: UIScreen.main.bounds.width, height: height)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if AuthoritySingleton.shared.faceRecognition && faceImageType == .people {
            return CGSize(width: UIScreen.main.bounds.width, height: carouselViewHeight + sumHeightMarginsForHeader)
        }
        return CGSize.zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let unwrapedObject = itemForIndexPath(indexPath: indexPath) else {
            return
        }
        
        if let smartItem = unwrapedObject as? PeopleItem, smartItem.responseObject.isDemo == true {
            delegate?.onSelectedFaceImageDemoCell(with: indexPath)
        } else if let smartItem = unwrapedObject as? ThingsItem, smartItem.responseObject.isDemo == true  {
            delegate?.onSelectedFaceImageDemoCell(with: indexPath)
        } else if let smartItem = unwrapedObject as? PlacesItem, smartItem.responseObject.isDemo == true  {
            delegate?.onSelectedFaceImageDemoCell(with: indexPath)
        } else if let smartItem = unwrapedObject as? PlacesItem, smartItem.isMapItemPlaceholder == true  {
            delegate?.onSelectedMapPlaceholderItem()
        } else {
            super.collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    // MARK: Utility methods
    func didAnimationForPremiumButton(with indexPath: IndexPath) {
        if let footerView = collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewPremiumFooter, for: indexPath) as? PremiumFooterCollectionReusableView {
            footerView.configureWithoutDetails(type: faceImageType, isSelectedAnimation: true)
            footerView.delegate = self
        }
    }
    
}

// MARK: - PremiumFooterCollectionReusableViewDelegate
extension FaceImageItemsDataSource: PremiumFooterCollectionReusableViewDelegate {
    func onBecomePremiumTap() {
        premiumDelegate?.onBecomePremiumTap()
    }
}


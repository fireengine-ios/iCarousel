//
//  PhotoVideoDataSourceForCollectionView.swift
//  Depo
//
//  Created by Aleksandr on 10/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class PhotoVideoDataSourceForCollectionView: BaseDataSourceForCollectionView {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let unwrapedObject = itemForIndexPath(indexPath: indexPath),
            let cell_ = cell as? CollectionViewCellDataProtocol else {
                return
        }
        
        cell_.updating()
        cell_.setSelection(isSelectionActive: isSelectionStateActive, isSelected: isObjctSelected(object: unwrapedObject))
        cell_.confireWithWrapperd(wrappedObj: unwrapedObject)
        cell_.setDelegateObject(delegateObject: self)
        
        guard let wraped = unwrapedObject as? Item else {
            return
        }
        
        switch wraped.patchToPreview {
        case .localMediaContent(let local):
            cell_.setAssetId(local.asset.localIdentifier)
            self.filesDataSource.getAssetThumbnail(asset: local.asset, indexPath: indexPath, completion: { (image, path) in
                DispatchQueue.main.async {
                    if cell_.getAssetId() == local.asset.localIdentifier, let image = image {
                        cell_.setImage(image: image, animated:  false)
                    } else {
                        cell_.setPlaceholderImage(fileType: wraped.fileType)
                    }
                }
            })
            
        case let .remoteUrl(url):
            if let url = url {
                cell_.setImage(with: url)
            } else {
                cell_.setPlaceholderImage(fileType: wraped.fileType)
            }
        }
        
        let countRow:Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastSection = Bool((numberOfSections(in: collectionView) - 1) == indexPath.section)
        let isLastCell = Bool((countRow - 1) == indexPath.row)
        
        let oldSectionNumbers = numberOfSections(in: collectionView)
        let containsEmptyMetaItems = !emptyMetaItems.isEmpty
        
//        if isLastCell, isLastSection, !isPaginationDidEnd {
//            if pageLeftOvers.isEmpty, !isLocalFilesRequested {
//                delegate?.getNextItems()
//            } else if !pageLeftOvers.isEmpty, !isLocalFilesRequested {
//                debugPrint("!!! page compunding for page \(lastPage)")
//                
//                compoundItems(pageItems: [], pageNum: lastPage, complition: { [weak self] response in
//                    self?.insertItems(with: response, emptyItems: [], oldSectionNumbers: oldSectionNumbers, containsEmptyMetaItems: containsEmptyMetaItems)
//                    
//                })
//            }
//            //            else {
//            //                delegate?.getNextItems()
//            //            }
//        } else if isLastCell, isLastSection, isPaginationDidEnd, isLocalPaginationOn, !isLocalFilesRequested {
//            compoundItems(pageItems: [], pageNum: 2, complition: { [weak self] response in
//                self?.insertItems(with: response, emptyItems: [], oldSectionNumbers: oldSectionNumbers, containsEmptyMetaItems: containsEmptyMetaItems)
//            })
//        }
//        
//        if let photoCell = cell_ as? CollectionViewCellForPhoto {
//            let file = itemForIndexPath(indexPath: indexPath)
//            if let `file` = file, uploadedObjectID.index(of: file.uuid) != nil {
//                photoCell.finishedUploadForObject()
//            }
//        }
        
        if let cell = cell as? BasicCollectionMultiFileCell {
            cell.moreButton.isHidden = !needShow3DotsInCell
        }
    }
    
}

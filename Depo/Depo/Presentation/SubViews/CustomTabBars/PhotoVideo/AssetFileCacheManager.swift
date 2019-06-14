//
//  AssetFileCacheManager.swift
//  Depo
//
//  Created by Konstantin on 9/25/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


typealias ItemProviderClosure = ((_ indexPath: IndexPath)-> PHAsset?)

class AssetFileCacheManager {
    
    private var filesDataSource = FilesDataSource()
    private var previousPreheatRect: CGRect = .zero
    
    
    func resetCachedAssets() {
        filesDataSource.stopCahcingAllImages()
        previousPreheatRect = .zero
    }
    
    func updateCachedAssets(on collectionView: UICollectionView?, itemProviderClosure: ItemProviderClosure) {
        // Update only if the view is visible.
        guard
            let collectionView = collectionView,
            let view = collectionView.superview,
            view.window != nil
        else {
            return
        }
        
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return
        }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .compactMap { itemProviderClosure($0) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .compactMap {  itemProviderClosure($0) }
        
        DispatchQueue.toBackground { [weak self] in
            // Update the assets the PHCachingImageManager is caching.
            self?.filesDataSource.startCahcingImages(for: addedAssets)
            //        print("Started \(addedAssets.count) request(s) of images")
            self?.filesDataSource.stopCahcingImages(for: removedAssets)
            //        print("Removed \(removedAssets.count) request(s) of images")
        }
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

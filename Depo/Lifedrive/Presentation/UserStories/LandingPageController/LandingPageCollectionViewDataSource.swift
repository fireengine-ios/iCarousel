//
//  LandingPageCollectionViewDataSource.swift
//  lifedrive
//
//  Created by Andrei Novikau on 10/21/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol LandingPageCollectionViewDataSourceDelegate: class {
    func pageIndexDidChange(_ newIndex: Int)
}

typealias LandingItem = (image: UIImage?, title: String, subtitle: String)

final class LandingPageCollectionViewDataSource: NSObject {
    
    private let collectionView: UICollectionView!
    private var currentPage = 0
    
    private weak var delegate: LandingPageCollectionViewDataSourceDelegate!
    private let titles = [TextConstants.landingBilloTitle0,
                          TextConstants.landingBilloTitle1,
                          TextConstants.landingBilloTitle2,
                          TextConstants.landingBilloTitle3,
                          TextConstants.landingBilloTitle4,
                          TextConstants.landingBilloTitle5,
                          TextConstants.landingBilloTitle6]
    
    private let subtitles = [TextConstants.landingBilloSubTitle0,
                             TextConstants.landingBilloSubTitle1,
                             TextConstants.landingBilloSubTitle2,
                             TextConstants.landingBilloSubTitle3,
                             TextConstants.landingBilloSubTitle4,
                             TextConstants.landingBilloSubTitle5,
                             TextConstants.landingBilloSubTitle6]
    
    // MARK: - Init
    
    init(collectionView: UICollectionView, delegate: LandingPageCollectionViewDataSourceDelegate) {
        self.collectionView = collectionView
        self.delegate = delegate
        super.init()
        self.setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.register(nibCell: LandingCollectionViewCell.self)
    }
    
    func updateCollectionViewLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = collectionView.bounds.size
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }
    
    func scroll(to page: Int) {
        collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    private func item(for indexPath: IndexPath) -> LandingItem {
        return LandingItem(image: UIImage(named: "LandingImage\(indexPath.item)"),
                           title: titles[indexPath.item],
                           subtitle: subtitles[indexPath.item])
    }
}

// MARK: - UICollectionViewDateSource

extension LandingPageCollectionViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NumericConstants.langingPageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: LandingCollectionViewCell.self, for: indexPath) 
        
        let landingItem = item(for: indexPath)
        cell.setup(with: landingItem)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension LandingPageCollectionViewDataSource: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        
        if currentPage != page {
            currentPage = page
            delegate.pageIndexDidChange(page)
        }
    }
}

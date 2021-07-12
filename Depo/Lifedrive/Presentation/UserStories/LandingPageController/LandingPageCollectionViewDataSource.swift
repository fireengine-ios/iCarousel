//
//  LandingPageCollectionViewDataSource.swift
//  lifedrive
//
//  Created by Andrei Novikau on 10/21/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol LandingPageCollectionViewDataSourceDelegate: AnyObject {
    func pageIndexDidChange(_ newIndex: Int)
}

typealias LandingItem = (image: UIImage?, title: String, subtitle: String)

final class LandingPageCollectionViewDataSource: NSObject {
    
    private let collectionView: UICollectionView!
    private var currentPage = 0
    
    private weak var delegate: LandingPageCollectionViewDataSourceDelegate!
    private let titles = [TextConstants.landingBilloTitle0,
                          TextConstants.landingBilloTitle3,
                          TextConstants.landingBilloTitle6,
                          TextConstants.landingBilloTitle2]
    
    private let subtitles = [TextConstants.landingBilloSubTitle0,
                             TextConstants.landingBilloSubTitle3,
                             TextConstants.landingBilloSubTitle6,
                             TextConstants.landingBilloSubTitle2]
    
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
        var image: UIImage?
        switch indexPath.row {
        case 0:
            image = UIImage(named: "LandingImage4")
        case 1:
            image = UIImage(named: "LandingImage3")
        case 2:
            image = UIImage(named: "LandingImage6")
        case 3:
            image = UIImage(named: "LandingImage2")
        default:
            image = nil
        }

        return LandingItem(image: image,
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

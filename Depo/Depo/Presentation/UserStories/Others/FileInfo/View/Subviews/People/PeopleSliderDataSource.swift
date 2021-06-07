//
//  PeopleSliderDataSource.swift
//  Depo
//
//  Created by Raman Harhun on 5/13/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol PeopleSliderDataSourceDelegate: class {
    func didSelect(item: PeopleOnPhotoItemResponse)
}

final class PeopleSliderDataSource: NSObject {
    
    private weak var collectionView: UICollectionView?
    private weak var delegate: PeopleSliderDataSourceDelegate?
    
    private(set) var items = [PeopleOnPhotoItemResponse]()
    
    //MARK: - Init
    
    required init(collectionView: UICollectionView, delegate: PeopleSliderDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        
        super.init()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView?.backgroundColor = .clear
        collectionView?.bounces = true
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(nibCell: PeopleCollectionViewCell.self)
    }
    
    //MARK: - Shared methods

    func reloadCollection(with items: [PeopleOnPhotoItemResponse]) {
        DispatchQueue.toMain {
            self.items = items
            self.collectionView?.reloadData()
            self.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    func deleteItem(at index: Int) {
        items.remove(at: index)
    }
    
    func reset() {
        items.removeAll()
        collectionView?.reloadData()
    }
}

//MARK: - UICollectionViewDataSource

extension PeopleSliderDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeue(cell: PeopleCollectionViewCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PeopleCollectionViewCell, let item = items[safe: indexPath.row] else {
            assertionFailure()
            return
        }
        
        cell.setup(with: item)
    }
}

//MARK: - UICollectionViewDelegate

extension PeopleSliderDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = items[safe: indexPath.row] else {
            return
        }
        delegate?.didSelect(item: selectedItem)
    }
}


extension PeopleSliderDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}



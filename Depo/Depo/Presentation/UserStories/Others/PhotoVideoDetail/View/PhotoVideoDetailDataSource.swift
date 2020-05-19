//
//  PhotoVideoDetailDataSource.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 5/17/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol PhotoVideoDetailDataSourceDelegate: class {
    func didSelectPeople(item: PeopleOnPhotoItemResponse)
}

final class PhotoVideoDetailDataSource: NSObject {
        
    private let padding: CGFloat = 1
    
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.baseFilesGreedCollectionDataSource)
    
    private let collectionView: UICollectionView
    private weak var delegate: PhotoVideoDetailDataSourceDelegate?
    private var albumSlider: PeopleSliderCell?
    
    private var isPaginationDidEnd = false
    
    private var items = [PeopleOnPhotoItemResponse]()
    
    private lazy var sliderCellSize: CGSize = {
        return CGSize(width: UIScreen.main.bounds.width, height: PeopleSliderCell.height)
    }()
    
    //MARK: - Init
    
    required init(collectionView: UICollectionView, delegate: PhotoVideoDetailDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        
        super.init()
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibCell: PeopleSliderCell.self)
        collectionView.allowsMultipleSelection = true
        collectionView.alwaysBounceVertical = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
    }
}

//MARK: - Public methods

extension PhotoVideoDetailDataSource {
    func reset() {
        photosReset()
        albumSliderReset()
        albumSlider?.appendItems(items)
    }
    
    func photosReset() {
        isPaginationDidEnd = false
        collectionView.reloadData()
    }
    
    func albumSliderReset() {
        albumSlider?.reset()
    }
    
    func appendItems(_ newItems: [PeopleOnPhotoItemResponse]) {
        items = newItems
        reset()
    }
}

//MARK: - UICollectionViewDataSource

extension PhotoVideoDetailDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: PeopleSliderCell.self, for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PeopleSliderCell else {
            return
        }
        
        if albumSlider == nil {
            albumSlider = cell
            albumSlider?.reset()
            albumSlider?.appendItems(items)
        }
        
        cell.delegate = self
        return
    }
}

//MARK: - UICollectionViewDelegate

extension PhotoVideoDetailDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
 
extension PhotoVideoDetailDataSource: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.bounds.width, height: PeopleSliderCell.height)
    }
}

//MARK: - PeopleSliderCellDelegate

extension PhotoVideoDetailDataSource: PeopleSliderCellDelegate {
    func didSelect(item: PeopleOnPhotoItemResponse) {
        delegate?.didSelectPeople(item: item)
    }
}

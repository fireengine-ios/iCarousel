//
//  SpotifyPlaylistsDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol SpotifyPlaylistsDataSourceDelegate: class {
    func needLoadNextPage()
    func onStartSelection()
    func onSelect(playlist: SpotifyPlaylist)
    func didChangeSelectionCount(newCount: Int)
}

final class SpotifyPlaylistsDataSource: NSObject {

    typealias PlaylistGroup = (key: String, value: [SpotifyPlaylist])
    
    private let collectionView: UICollectionView
    
    private weak var delegate: SpotifyPlaylistsDataSourceDelegate?

    private var allData = [SpotifyPlaylist]()
    private(set) var playlists = [PlaylistGroup]()
    var sectionNames = [String]()
    
    var selectedPlaylists: [SpotifyPlaylist] {
        get {
            if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
                return selectedIndexPaths.compactMap { item(for: $0) }
            }
            return []
        }
    }
    
    private(set) var isSelectionStateActive = false
    
    var isPaginationDidEnd = false
    
    // MARK: -
    
    required init(collectionView: UICollectionView, delegate: SpotifyPlaylistsDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
        super.init()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibCell: SpotifyCollectionViewCell.self)
        collectionView.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self, kind: UICollectionElementKindSectionHeader)
        collectionView.allowsMultipleSelection = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 70)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }
    
    func append(_ newPlaylists: [SpotifyPlaylist]) {
        guard !newPlaylists.isEmpty else {
            isPaginationDidEnd = true
            return
        }
        
        let reload = allData.isEmpty
        allData.append(contentsOf: newPlaylists)
        playlists = Dictionary(grouping: allData, by: { String($0.name.first ?? Character("")) }).sorted {$0.0 < $1.0}
        sectionNames = playlists.map { $0.key }
        
        if reload {
            collectionView.reloadData()
        } else {
            var insertedIndexPaths = [IndexPath]()
            playlists.enumerated().forEach { section, array in
                array.value.enumerated().forEach { row, playlist in
                    if newPlaylists.contains(playlist) {
                        insertedIndexPaths.append(IndexPath(row: row, section: section))
                    }
                }
            }
            if !insertedIndexPaths.isEmpty {
                collectionView.performBatchUpdates ({
                    collectionView.insertItems(at: insertedIndexPaths)
                })
            }
        }
    }
    
    private func item(for indexPath: IndexPath) -> SpotifyPlaylist? {
        return playlists[safe: indexPath.section]?.value[safe: indexPath.row]
    }
    
    private func headerText(at section: Int) -> String {
        if let firstLetter = playlists[safe: section]?.value.first?.name.first {
            return String(firstLetter)
        }
        return ""
    }
    
    func startSelection(with indexPath: IndexPath? = nil) {
        isSelectionStateActive = true
        if let indexPath = indexPath {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        }
        updateVisibleCells()
    }
    
    func cancelSelection() {
        isSelectionStateActive = false
        
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            selectedItems.forEach { collectionView.deselectItem(at: $0, animated: false) }
        }
        updateVisibleCells()
    }
    
    private func updateVisibleCells() {
        collectionView.visibleCells.forEach { ($0 as? SpotifyCollectionViewCell)?.setSelectionMode(isSelectionStateActive, animation: true) }
    }
    
    func selectAll() {
        collectionView.selectAll(nil)
    }
}

// MARK: - UICollectionViewDataSource

extension SpotifyPlaylistsDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists[section].value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: SpotifyCollectionViewCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SpotifyCollectionViewCell,
              let playlist = item(for: indexPath) else {
              return
        }
        cell.setup(with: playlist)
        cell.setSelectionMode(isSelectionStateActive, animation: false)
        cell.delegate = self
        
        if isPaginationDidEnd {
            return
        }
        
        let countRow: Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastSection = numberOfSections(in: collectionView) - 1 == indexPath.section
        let isLastCell = countRow - 1 == indexPath.row
        
        if isLastSection, isLastCell {
            delegate?.needLoadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeue(supplementaryView: CollectionViewSimpleHeaderWithText.self, kind: kind, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        /// fixing iOS11 UICollectionSectionHeader clipping scroll indicator
        /// https://stackoverflow.com/a/46930410/5893286
        if #available(iOS 11.0, *), elementKind == UICollectionElementKindSectionHeader {
            view.layer.zPosition = 0
        }
        guard let view = view as? CollectionViewSimpleHeaderWithText else {
            return
        }
        
        view.setText(text: headerText(at: indexPath.section))
    }
}

// MARK: - UICollectionViewDelegate

extension SpotifyPlaylistsDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isSelectionStateActive, let playlist = item(for: indexPath) {
            delegate?.onSelect(playlist: playlist)
        } else {
            delegate?.didChangeSelectionCount(newCount: collectionView.indexPathsForSelectedItems?.count ?? 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.didChangeSelectionCount(newCount: collectionView.indexPathsForSelectedItems?.count ?? 0)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SpotifyPlaylistsDataSource: UICollectionViewDelegateFlowLayout {
    
}

// MARK: - LBCellsDelegate

extension SpotifyPlaylistsDataSource: LBCellsDelegate {
    func canLongPress() -> Bool {
        return true
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        if !isSelectionStateActive {
            if let indexPath = collectionView.indexPath(for: cell) {
                startSelection(with: indexPath)
            }
            delegate?.onStartSelection()
        }
    }
}

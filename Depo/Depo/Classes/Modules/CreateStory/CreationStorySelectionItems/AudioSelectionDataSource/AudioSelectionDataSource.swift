//
//  AudioSelectionDataSource.swift
//  Depo
//
//  Created by Oleg on 03.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class AudioSelectionDataSource: ArrayDataSourceForCollectionView, AudioSelectionCollectionViewCellDelegate {
    
    let smallPlayer = SmallBasePlayer()
    
    override func setupCollectionView(collectionView: UICollectionView, filters: [GeneralFilesFiltrationType]?){
        super.setupCollectionView(collectionView: collectionView, filters: [.fileType(.audio)])
        let nib = UINib(nibName: CollectionViewCellsIdsConstant.audioSelectionCell, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.audioSelectionCell)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellsIdsConstant.audioSelectionCell, for: indexPath)
        
        return  cell
    }
    
    
    // MARK: AudioSelectionCollectionViewCellDelegate
    
    func onPlayButton(inCell: AudioSelectionCollectionViewCell){
        let indexPath = collectionView.indexPath(for: inCell)
        guard let path = indexPath else {
            return
        }
        let object = itemForIndexPath(indexPath: path)
        
        guard let unwrapedObject = object as? Item else {
            return
        }
        
        SingleSong.default.stop()
        
        
        inCell.playingButton.isSelected ? smallPlayer.stop() : smallPlayer.playWithItem(object: unwrapedObject)
        
        unplayOtherCells(currentlyPlayingCell: inCell)
   
        inCell.changeButtonState(playing: smallPlayer.isPlaying())
    }
    
    private func unplayOtherCells(currentlyPlayingCell: AudioSelectionCollectionViewCell) {
        collectionView.visibleCells.forEach {
            if let audioCell = $0 as? AudioSelectionCollectionViewCell, audioCell != currentlyPlayingCell {
                audioCell.changeButtonState(playing: false)//playingButton.isSelected = false
            }
        }
    }

}

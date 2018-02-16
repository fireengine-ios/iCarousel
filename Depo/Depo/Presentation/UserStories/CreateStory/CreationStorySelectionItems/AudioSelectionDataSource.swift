//
//  AudioSelectionDataSource.swift
//  Depo
//
//  Created by Oleg on 03.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class AudioSelectionDataSource: ArrayDataSourceForCollectionView, AudioSelectionCollectionViewCellDelegate {
    
    lazy var player: MediaPlayer = factory.resolve()
    private lazy var smallPlayer: MediaPlayer = MediaPlayer()
    
    override func setupCollectionView(collectionView: UICollectionView, filters: [GeneralFilesFiltrationType]?){
        super.setupCollectionView(collectionView: collectionView, filters: [.fileType(.audio)])
        let nib = UINib(nibName: CollectionViewCellsIdsConstant.audioSelectionCell, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.audioSelectionCell)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: AudioSelectionCollectionViewCell.self, for: indexPath)
        if smallPlayer.isPlaying {
            let item = tableDataMArray[indexPath.section][indexPath.row]
            cell.playingButton.isSelected = isObjectPlaying(item: item)
        } else {
            cell.playingButton.isSelected = false
        }
        return cell
    }
    
    override func isObjctSelected(object: BaseDataSourceItem) -> Bool {
        if let firstObject = selectedItemsArray.first as? WrapData, let item = object as? WrapData{
            if firstObject.metaData != nil{
                return firstObject.uuid == item.uuid
            }else{
                return firstObject.id == item.id
            }
        }
        return false
    }
    
    func isObjectPlaying(item: BaseDataSourceItem) -> Bool {
        guard let item = item as? Item, let itemThatPlayingRightNow = smallPlayer.currentItem else{
            return false
        }
        
        if itemThatPlayingRightNow.metaData != nil, item.metaData != nil{
            return itemThatPlayingRightNow.uuid == item.uuid
        }else{
            return itemThatPlayingRightNow.id == item.id
        }
    }
    
    
    // MARK: AudioSelectionCollectionViewCellDelegate
    
    func onPlayButton(inCell: AudioSelectionCollectionViewCell){
        let indexPath = collectionView?.indexPath(for: inCell)
        guard let path = indexPath else {
            return
        }
        let object = itemForIndexPath(indexPath: path)
        
        guard let unwrapedObject = object as? Item else {
            return
        }
        
        player.stop()
        
        inCell.playingButton.isSelected ? smallPlayer.stop() : smallPlayer.play(list: [unwrapedObject], startAt: 0)
        
        unplayOtherCells(currentlyPlayingCell: inCell)
   
        inCell.changeButtonState(playing: smallPlayer.isPlaying)
    }
    
    private func unplayOtherCells(currentlyPlayingCell: AudioSelectionCollectionViewCell) {
        collectionView?.visibleCells.forEach {
            if let audioCell = $0 as? AudioSelectionCollectionViewCell, audioCell != currentlyPlayingCell {
                audioCell.changeButtonState(playing: false)
            }
        }
    }

}

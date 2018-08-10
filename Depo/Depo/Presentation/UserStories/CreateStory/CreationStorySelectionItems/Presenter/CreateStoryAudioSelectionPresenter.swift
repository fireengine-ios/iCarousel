//
//  CreateStoryAudioSelectionPresenter.swift
//  Depo
//
//  Created by Oleg on 02.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CreateStoryAudioSelectionPresenter: DocumentsGreedPresenter, CreateStorySelectionInteractorOutput {
    
    var photoStory: PhotoStory?
    
    override func viewIsReady(collectionView: UICollectionView) {
        dataSource = AudioSelectionDataSource()
        super.viewIsReady(collectionView: collectionView)
        dataSource.canReselect = true
        dataSource.maxSelectionCount = NumericConstants.maxNumberAudioInStory
        dataSource.enableSelectionOnHeader = false
        dataSource.setSelectionState(selectionState: true)
        dataSource.updateDisplayngType(type: .list)
    }
    
    override func isArrayDataSource() -> Bool {
        return true
    }
    
    override func viewWillDisappear() {

    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) {
    }
    
    override func onNextButton() {
        guard  let story = photoStory else {
            return
        }
        if let music = dataSource.selectedItemsArray.first as? Item {
            story.music = music
            interactor.trackItemsSelected()
            if let viewController = view as? CreateStoryAudioSelectionViewController {
               viewController.hideView()
            }
        } else {
            UIApplication.showErrorAlert(message: TextConstants.createStoryNoSelectedAudioError)
        }
        
        player.stop()
    }
    
    func configurateWithPhotoStory(story: PhotoStory) {
        photoStory = story
        if let music = story.music {
            dataSource.onSelectObject(object: music)
        }
    }
    
    override func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: 46)
    }
    
    func onChangeSource(isYourUpload: Bool) {
        if let interactor = interactor as? CreateStorySelectionInteractor {
            if let dataSource = dataSource as? AudioSelectionDataSource {
                dataSource.tableDataMArray.removeAll()
            }
            interactor.onChangeSorce(isYourUpload: isYourUpload)
            needReloadData()
        }
    }
}

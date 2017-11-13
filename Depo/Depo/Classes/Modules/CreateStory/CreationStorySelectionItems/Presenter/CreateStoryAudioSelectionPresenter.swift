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
    
    override func viewWillDisappear() {

    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int){
        //view.setTitle(title: "", subTitle: "")
    }
    
    override func onNextButton() {
        guard  let story = photoStory else {
            return
        }
        let array = dataSource.getSelectedItems()
        if (array.count > 0){
            guard let music = array.first! as? Item else{
                return
            }
            story.music = music
            if let viewController = view as? CreateStoryAudioSelectionViewController{
               viewController.hideView()
            }
        }else{
            custoPopUp.showCustomAlert(withText: TextConstants.createStoryNoSelectedAudioError, okButtonText: TextConstants.createFolderEmptyFolderButtonText)
        }
        
//        SingleSong.default.stop()
        player.stop()
    }
    
    func configurateWithPhotoStory(story: PhotoStory){
        photoStory = story
        if let music = story.music{
            dataSource.onSelectObject(object: music)
        }
    }
    
    override func getCellSizeForList() -> CGSize{
        return CGSize(width: view.getCollectionViewWidth(), height: 46)
    }
    
//    override func getContentWithSuccess(array: [[WrapData]]){
//        if (view == nil){
//            return
//        }
//        //
//        asyncOperationSucces()
//        view.stopRefresher()
//        if let dataSourceForArray = dataSource as? ArrayDataSourceForCollectionView{
//            dataSourceForArray.configurateWithArray(array: array)
//        }else{
//            dataSource.reloadData()
//        }
//    }

}

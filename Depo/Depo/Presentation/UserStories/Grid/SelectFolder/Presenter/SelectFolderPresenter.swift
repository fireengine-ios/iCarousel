//
//  SelectFolderPresenter.swift
//  Depo
//
//  Created by Oleg on 07/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SelectFolderPresenter: DocumentsGreedPresenter{

    override func viewIsReady(collectionView: UICollectionView) {
        
        super.viewIsReady(collectionView: collectionView)
                
        log.debug("SelectFolderPresenter viewIsReady")
        
        dataSource.canSelectionState = false
        dataSource.canReselect = false
        dataSource.enableSelectionOnHeader = false
        dataSource.maxSelectionCount = 0
        dataSource.setSelectionState(selectionState: false)
        dataSource.updateDisplayngType(type: .list)
    }
    
    override func onNextButton(){
        log.debug("SelectFolderPresenter onNextButton")

        if let view_ = view as? SelectFolderViewController {
            if (view_.selectedFolder != nil) {
                view_.onFolderSelected(folderID: view_.selectedFolder!.uuid)
            } else {
                view_.onFolderSelected(folderID: "")
            }
        }
    }
    
//     func getContentWithSuccess(files: [BaseDataSourceItem]){
//        super .getContentWithSuccess(files: files)
//    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data:[[BaseDataSourceItem]]) {
        log.debug("SelectFolderPresenter onItemSelected")

        guard let wraperd = item as? Item else {
            return
        }
        let router = RouterVC()
        let folderSelector = router.selectFolder(folder: wraperd, sortRule: sortedRule)
        if let view_ = view as? SelectFolderViewController {
            folderSelector.selectFolderBlock = view_.selectFolderBlock
            view_.navigationController?.pushViewController(folderSelector, animated: true)
        }
    }
    
    override func onLongPressInCell() {
        
    }
    
}

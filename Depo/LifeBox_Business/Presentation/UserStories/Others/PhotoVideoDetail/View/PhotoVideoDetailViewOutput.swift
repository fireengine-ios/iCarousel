//
//  PhotoVideoDetailPhotoVideoDetailViewOutput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PhotoVideoDetailViewOutput {
    
    func viewIsReady(view: UIView)
    
    func setSelectedItemIndex(selectedIndex: Int)
    
    func onInfo(object: Item)
    
    func viewWillDisappear()

    func startCreatingAVAsset()
    func stopCreatingAVAsset()

    func moreButtonPressed(sender: Any?, inAlbumState: Bool, object: Item, selectedIndex: Int)
    
    func updateBars()
    func updateBottomBar()
    
    func replaceUploaded(_ item: WrapData)
    
    func videoStarted()
    func videoStoped()
    
    func willDisplayLastCell()
    
    func tabIndex(type: ElementTypes) -> Int?
    
    func createNewUrl(at index: Int)
}

//
//  PhotoVideoDetailPhotoVideoDetailViewOutput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoVideoDetailViewOutput {
    
    func viewIsReady(view: UIView)
    
    func setSelectedItemIndex(selectedIndex: Int)
    
    func onInfo(object: Item)
    
    func viewWillDisappear()
    func viewFullyLoaded()
    

    func startCreatingAVAsset()
    func stopCreatingAVAsset()

    func moreButtonPressed(sender: Any?, inAlbumState: Bool, object: Item, selectedIndex: Int)
    
    func updateBars()
    func updateBottomBar()
    
    func replaceUploaded(_ item: WrapData)
    
    func videoStarted()
    func videoStoped()
    
    func willDisplayLastCell()
    
    func getFIRStatus(completion: VoidHandler?)

    func configureFileInfo(_ view: FileInfoView)
    func getPersonsForSelectedPhoto(completion: VoidHandler?)
    
    func tabIndex(type: ElementTypes) -> Int?
    
    func createNewUrl()

    func recognizeTextForCurrentItem(image: UIImage, completion: @escaping (ImageTextSelectionData) -> Void)
}

//
//  PhotoVideoDetailPhotoVideoDetailInteractorInput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoVideoDetailInteractorInput: AnyObject {
    
    func onSelectItem(fileObject: Item, from items: [Item])
    
    func onViewIsReady()
    
    var currentItemIndex: Int? { get set }
    
    var allItems: [Item] { get }

    func bottomBarConfig(for selectedIndex: Int) -> EditingBarConfig

    func deleteSelectedItem(type: ElementTypes)
    
    var setupedMoreMenuConfig: [ElementTypes] { get }
    
    func trackVideoStart()
    func trackVideoStop()
    
    func replaceUploaded(_ item: WrapData)
    
    func updateExpiredItem(_ item: WrapData)
    
    func appendItems(_ items: [Item])
    
    func onRename(newName: String)

    func onEditDescription(newDescription: String)
    
    func onValidateName(newName: String)

    func onValidateDescription(newDescription: String) 
    
    func getPersonsOnPhoto(uuid: String, completion: VoidHandler?)
    
    func getPeopleAlbum(with item: PeopleItem, id: Int64)

    func enableFIR(completion: VoidHandler?)
    
    func getFIRStatus(success: @escaping (SettingsInfoPermissionsResponse) -> (), fail: @escaping (Error) -> ())
    
    func getAuthority()
    
    func createNewUrl()

    func resignUserActivity()

    func recognizeTextForCurrentItem(image: UIImage, completion: @escaping (ImageTextSelectionData) -> Void)
}

//
//  FaceImageItemsInteractorOutput.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImageItemsInteractorOutput {
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item)
    func didSaveChanges(_ items: [PeopleItem])
    func didShowPopUp()
}

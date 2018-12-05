//
//  FaceImageFilesInteractorInput.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol FaceImageItemsInteractorInput {
    func loadItem(_ item: BaseDataSourceItem)
    func onSaveVisibilityChanges(_ items: [PeopleItem])
    func checkPhotos()
    func changeCheckPhotosState(isCheckPhotos: Bool)
    
    func getFeaturePacks(group: DispatchGroup?)
    func getInfoForAppleProducts(offer: PackageModelResponse, accountType: AccountType, group: DispatchGroup?)
}

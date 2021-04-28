//
//  PhotoVideoDetailPhotoVideoDetailModuleInput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PhotoVideoDetailModuleInput: BaseItemInputPassingProtocol {
    var itemsType: FileType? { get }
    func appendItems(_ items: [Item], isLastPage: Bool)
}

//
//  FaceImageItemsViewInput.swift
//  Depo
//
//  Created by Harbros on 13.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol FaceImageItemsViewInput: class {
    func configurateUgglaView()
    func updateUgglaViewPosition()
    func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String, needHideTopBar: Bool, isShowUggla: Bool)
}

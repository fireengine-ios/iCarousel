//
//  FaceImageItemsViewInput.swift
//  Depo
//
//  Created by Harbros on 13.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol FaceImageItemsViewInput: class {
    func configurateUgglaView(hidden: Bool)
    func updateUgglaViewPosition()
    func showUgglaView()
    func hideUgglaView()
    func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String, needHideTopBar: Bool, isShowUggla: Bool)
    func updateShowHideButton(isShow: Bool)
}

//
//  FaceImagePhotosViewInput.swift

//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/7/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol FaceImagePhotosViewInput: AnyObject {
    var contentView: UIView! { get }
    func setHeaderImage(with path: PathForItem)
    func setupHeader(with item: Item, status: ItemStatus?)
    func reloadName(_ name: String)
    func hiddenSlider(isHidden: Bool)
    func setCountImage(_ count: String)
    func reloadSlider()
}

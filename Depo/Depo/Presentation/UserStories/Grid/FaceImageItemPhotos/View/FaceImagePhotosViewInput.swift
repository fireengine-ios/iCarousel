//
//  FaceImagePhotosViewInput.swift

//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/7/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol FaceImagePhotosViewInput: class {
    func setHeaderImage(with path: PathForItem)
    func setupHeader(forPeopleItem item: PeopleItem?)
    func reloadName(_ name: String)
    func dismiss()
}

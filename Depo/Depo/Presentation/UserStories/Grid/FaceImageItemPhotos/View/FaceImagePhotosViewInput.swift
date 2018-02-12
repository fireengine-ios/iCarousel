//
//  FaceImagePhotosViewInput.swift

//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/7/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol FaceImagePhotosViewInput: class {
    func setHeaderImage(with url: URL)
    func loadAlbumsForPeopleItem(_ peopleItem: PeopleItem)
    func setHeaderViewHidden(_ isHidden: Bool)
    func reloadName(_ name: String)
}

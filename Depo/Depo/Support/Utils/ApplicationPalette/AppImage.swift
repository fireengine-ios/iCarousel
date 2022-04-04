//
//  AppImage.swift
//  Depo
//
//  Created by Hady on 4/1/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol AppImage {
    var name: String { get }
}

extension AppImage where Self: RawRepresentable, RawValue == String {
    var name: String { rawValue }
}

func image(_ appImage: AppImage) -> UIImage {
    guard let image = UIImage(named: appImage.name) else {
        assertionFailure()
        return UIImage()
    }

    return image
}

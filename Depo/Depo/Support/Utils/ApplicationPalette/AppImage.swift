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

func imageAsset(_ appImage: AppImage) -> UIImage {
    guard let image = UIImage(named: appImage.name) else {
        assertionFailure("Image not found with name \(appImage.name)")
        return UIImage()
    }

    return image
}

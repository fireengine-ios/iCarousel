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

extension AppImage {
    var image: UIImage {
        guard let image = UIImage(named: name) else {
            assertionFailure("Image not found with name: \(name)")
            return UIImage()
        }

        return image
    }
}

extension AppImage where Self: RawRepresentable, RawValue == String {
    var name: String { rawValue }
}

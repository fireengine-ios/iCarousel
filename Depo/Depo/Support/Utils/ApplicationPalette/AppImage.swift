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

enum ImageTintMode {
    case none
    case color(_ value: AppColor)
}

extension AppImage {
    var image: UIImage {
        guard let image = UIImage(named: name) else {
            assertionFailure("Image not found with name: \(name)")
            return UIImage()
        }

        return image
    }

    func image(withTintMode tintMode: ImageTintMode) -> UIImage {
        switch tintMode {
        case .none:
            return image
        case .color(let tintColor):
            if #available(iOS 13.0, *) {
                return image.withTintColor(tintColor.color, renderingMode: .alwaysTemplate)
            } else {
                return image.withRenderingMode(.alwaysTemplate)
            }
        }
    }
}

extension AppImage where Self: RawRepresentable, RawValue == String {
    var name: String { rawValue }
}

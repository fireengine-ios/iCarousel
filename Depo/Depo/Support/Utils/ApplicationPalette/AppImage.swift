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

    @available(iOS, deprecated: 13.0, message: "Remove the view parameter once the minimum is updated to iOS 13")
    func image(withTintColor tintColor: AppColor, in view: UIView) -> UIImage {
        if #available(iOS 13.0, *) {
            return image.withTintColor(tintColor.color, renderingMode: .alwaysTemplate)
        } else {
            view.tintColor = tintColor.color
            return image.withRenderingMode(.alwaysTemplate)
        }
    }
}

extension AppImage where Self: RawRepresentable, RawValue == String {
    var name: String { rawValue }
}

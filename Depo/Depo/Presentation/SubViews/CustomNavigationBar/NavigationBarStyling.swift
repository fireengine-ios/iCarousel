//
//  NavigationBarStyling.swift
//  Lifebox
//
//  Created by Hady on 3/31/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

protocol NavigationBarStyling: UIViewController {
    var preferredNavigationBarStyle: NavigationBarStyle { get }
}

extension NavigationBarStyling {
    func configureNavigationBarStyle() {
        switch preferredNavigationBarStyle {
        case .default:
            navigationItem.titleView = nil

        case .withLogo:
            let size = preferredNavigationBarStyle.titleViewSize
            let titleView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let imageView = UIImageView(image: imageAsset(NavigationBarImages.logo))
            titleView.addSubview(imageView)
            imageView.frame = titleView.bounds

            navigationItem.titleView = titleView

        case .black:
            navigationItem.titleView = nil
        }

        configureNavigationBar(with: preferredNavigationBarStyle)
    }

    private func configureNavigationBar(with style: NavigationBarStyle) {
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }

        navigationBar.barTintColor = style.barTintColor
        navigationBar.tintColor = style.tintColor
        navigationBar.titleTextAttributes = [
            .foregroundColor: style.titleColor,
//            .font TODO: Facelift: font
        ]
        navigationBar.isTranslucent = style.isTranslucent

        if #available(iOS 13.0, *) {
            configureNavigationItemAppearance(with: style)
        }
    }

    @available(iOS 13.0, *)
    private func configureNavigationItemAppearance(with style: NavigationBarStyle) {
        navigationItem.standardAppearance = standardNavigationBarAppearance(for: style)
        navigationItem.compactAppearance = standardNavigationBarAppearance(for: style)

        navigationItem.scrollEdgeAppearance = scrollEdgeNavigationBarAppearance(for: style)
        if #available(iOS 15.0, *) {
            navigationItem.compactScrollEdgeAppearance = scrollEdgeNavigationBarAppearance(for: style)
        }
    }

}

@available(iOS 13.0, *)
private func standardNavigationBarAppearance(for style: NavigationBarStyle) -> UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    configure(appearance: appearance, with: style)
    return appearance
}

@available(iOS 13.0, *)
private func scrollEdgeNavigationBarAppearance(for style: NavigationBarStyle) -> UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    configure(appearance: appearance, with: style)

    appearance.shadowColor = nil
    appearance.shadowImage = nil
    return appearance
}

@available(iOS 13.0, *)
private func configure(appearance: UINavigationBarAppearance, with style: NavigationBarStyle) {
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = style.barTintColor
    appearance.titleTextAttributes = [
        .foregroundColor: style.titleColor,
//            .font TODO: Facelift: font
    ]

    appearance.buttonAppearance.normal.titleTextAttributes = [
        .foregroundColor: style.tintColor,
//            .font TODO: Facelift: font
    ]
    appearance.setBackIndicatorImage(style.backIndicatorImage,
                                     transitionMaskImage: style.backIndicatorTransitionMaskImage)
    appearance.backButtonAppearance.normal.titlePositionAdjustment = style.backButtonTitlePositionAdjustment
}

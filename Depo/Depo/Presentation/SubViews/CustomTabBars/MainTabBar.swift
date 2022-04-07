//
//  MainTabBar.swift
//  Depo
//
//  Created by Hady on 4/7/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

final class MainTabBar: UITabBar {
    static let standardHeight: CGFloat = 70

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: Self.standardHeight)
    }

    func setupItems() {
        let items: [UITabBarItem] = TabBarItem.allCases.map { item in
            let tabBarItem = UITabBarItem(title: item.title, image: item.image, selectedImage: item.selectedImage)
            tabBarItem.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)

            if !item.accessibilityLabel.isEmpty {
                tabBarItem.accessibilityLabel = item.accessibilityLabel
            }

            return tabBarItem
        }

        setItems(items, animated: false)
    }

    private func setupStyle() {
        layer.cornerRadius = 16
        clipsToBounds = true

        isTranslucent = true
        backgroundColor = nil
        backgroundImage = nil
        shadowImage = nil
        barTintColor = nil
        unselectedItemTintColor = color(.tabBarTint)
        tintColor = color(.tabBarTintSelected)

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()

            appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
            appearance.stackedLayoutAppearance.normal.iconColor = color(.tabBarTint)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: color(.tabBarTint),
            ]
            appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -9)
            appearance.stackedLayoutAppearance.selected.iconColor = color(.tabBarTintSelected)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: color(.tabBarTintSelected),
            ]

            standardAppearance = appearance
            if #available(iOS 15.0, *) {
                scrollEdgeAppearance = appearance
            }
        }
    }
}

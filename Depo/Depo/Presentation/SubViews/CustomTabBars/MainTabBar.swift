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

    private let kItemTitleFontSize: CGFloat = 12
    private let kItemImageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)
    private let kTitlePositionAdjustment = UIOffset(horizontal: 0, vertical: -9)
    private let kCornerRadius: CGFloat = 16

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
            tabBarItem.imageInsets = kItemImageInsets

            if !item.accessibilityLabel.isEmpty {
                tabBarItem.accessibilityLabel = item.accessibilityLabel
            }

            return tabBarItem
        }

        setItems(items, animated: false)
    }

    private func setupStyle() {
        layer.cornerRadius = kCornerRadius
        clipsToBounds = true

        isTranslucent = true
        backgroundColor = nil
        backgroundImage = nil
        shadowImage = nil
        barTintColor = nil
        unselectedItemTintColor = AppColor.tabBarUnselect.color
        tintColor = AppColor.tabBarSelect.color

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()

            appearance.backgroundEffect = UIBlurEffect(style: .prominent)
            appearance.stackedLayoutAppearance.normal.iconColor = AppColor.tabBarUnselect.color
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: AppColor.tabBarUnselect.color,
                .font: UIFont.appFont(.medium, size: kItemTitleFontSize)
            ]
            
            appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = kTitlePositionAdjustment
            appearance.stackedLayoutAppearance.selected.iconColor = AppColor.tabBarSelect.color
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: AppColor.tabBarSelect.color,
                .font: UIFont.appFont(.bold, size: kItemTitleFontSize)
            ]

            standardAppearance = appearance
            if #available(iOS 15.0, *) {
                scrollEdgeAppearance = appearance
            }
        }
    }
}

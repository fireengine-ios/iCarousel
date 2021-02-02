//
//  TabBarConfigurator.swift
//  Depo
//
//  Created by Andrei Novikau on 22.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum TabScreenIndex: Int {
    case myDisk = 0
    case sharedFiles = 1
    case sharedArea = 2
}

enum TabBarItem: CaseIterable {
    case myDisk
    case sharedFiles
    case sharedArea
    
    var title: String {
        switch self {
        case .myDisk:
            return TextConstants.tabBarItemMyDisk
        case .sharedFiles:
            return TextConstants.tabBarItemSharedFiles
        case .sharedArea:
            return TextConstants.tabBarItemSharedArea
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .myDisk:
            return UIImage(named: "disks")
        case .sharedFiles:
            return UIImage(named: "share")
        case .sharedArea:
            return UIImage(named: "publicSpace")
        }
    }
    
    var accessibilityLabel: String {
        return title
    }
}

final class TabBarConfigurator {
    
    static func generateControllers(router: RouterVC) -> [UINavigationController] {
        let list = [router.myDisk,
                    router.sharedFiles,
                    router.sharedAreaController]
        list.forEach { ($0 as? BaseViewController)?.isTabBarItem = true }
        return list.compactMap { NavigationController(rootViewController: $0) }
    }
}

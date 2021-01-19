//
//  TabBarConfigurator.swift
//  Depo
//
//  Created by Andrei Novikau on 22.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum TabScreenIndex: Int {
    case documents = 0
    case sharedFiles = 1
    case sharedArea = 3
    case setting = 4
}

enum TabBarItem: CaseIterable {
    case myDisk
    case sharedFiles
    case plus
    case sharedArea
    case settings
    
    var title: String {
        switch self {
        case .myDisk:
            return TextConstants.tabBarItemMyDisk
        case .sharedFiles:
            return TextConstants.tabBarItemSharedFiles
        case .plus:
            return ""
        case .sharedArea:
            return TextConstants.tabBarItemSharedArea
        case .settings:
            return TextConstants.tabBarItemSettings
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .myDisk:
            return UIImage(named: "outlineDocs")
        case .sharedFiles:
            return UIImage(named: "segment_shared")
        case .plus:
            return UIImage(named: "")
        case .sharedArea:
            return UIImage(named: "segment_shared")
        case .settings:
            return UIImage(named: "cog")
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .myDisk:
            return TextConstants.homeButtonAllFiles
        default:
            return ""
        }
    }
}

final class TabBarConfigurator {
    
    static func generateControllers(router: RouterVC) -> [UINavigationController] {
        var settings = router.settings
        (settings as? BaseViewController)?.needToShowTabBar = true
        (settings as? BaseViewController)?.isTabBarItem = true
        if Device.isIpad {
            settings = router.settingsIpad(settingsController: settings)
        }
        
        let list = [router.myDisk,
                    router.sharedFiles,
                    router.sharedAreaController,
                    settings]
        list.forEach { ($0 as? BaseViewController)?.isTabBarItem = true }
        return list.compactMap { NavigationController(rootViewController: $0!) }
    }
}

//
//  BestSceneAllGroupSortedInitializer.swift
//  Depo
//
//  Created by Rustam Manafov on 04.03.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class BestSceneAllGroupSortedInitializer {
    class func initializeController(coverPhotoUrl: String, fileListUrls: [String]) -> UIViewController {
    
        let viewController = BestSceneAllGroupSortedViewController(coverPhotoUrl: coverPhotoUrl, fileListUrls: fileListUrls)
        
        return viewController
    }
}

//
//  FaceImageChangeCoverRouter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageChangeCoverRouter: BaseFilesGreedRouter {
    
}

// MARK: - FaceImageChangeCoverRouterInput

extension FaceImageChangeCoverRouter: FaceImageChangeCoverRouterInput {
    
    func back() {
        RouterVC().popViewController()
    }
    
}

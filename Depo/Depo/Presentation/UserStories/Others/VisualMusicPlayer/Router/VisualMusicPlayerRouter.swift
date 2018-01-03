//
//  VisualMusicPlayerVisualMusicPlayerRouter.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class VisualMusicPlayerRouter: VisualMusicPlayerRouterInput {
    
    weak var view: VisualMusicPlayerViewController!

    func dismiss() {
        view.navigationController?.dismiss(animated: true, completion: {})
    }
}

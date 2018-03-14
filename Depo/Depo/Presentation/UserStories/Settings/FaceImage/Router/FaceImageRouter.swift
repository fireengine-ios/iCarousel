//
//  FaceImageRouter.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class FaceImageRouter {
    
}

// MARK: - ImportFromInstagramInteractorOutput

extension FaceImageRouter: FaceImageRouterInput {
    
    func showPopUp() {
        let popUp = PopUpController.with(title: "", message: TextConstants.faceImageWaitAlbum, image: PopUpImage.none, buttonTitle: TextConstants.ok)
        
        RouterVC().presentViewController(controller: popUp)
    }

    
}

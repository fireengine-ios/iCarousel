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
        let popUp = PopUpController.with(title: nil, message: TextConstants.faceImageWaitAlbum, image: .none, buttonTitle: TextConstants.ok)
        
        RouterVC().presentViewController(controller: popUp)
    }

}

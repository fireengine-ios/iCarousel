//
//  FaceImageAddNameRouter.swift
//  Depo
//
//  Created by Harhun Brothers on 07.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class FaceImageAddNameRouter: BaseFilesGreedRouter, FaceImageAddNameRouterInput {
    func showMerge(firstUrl: URL, secondUrl: URL, completion: @escaping (() -> Void)) {
        
        let vc = PopUpController.with(title: TextConstants.faceImageCheckTheSamePerson, message: TextConstants.faceImageWillMergedTogether, firstUrl: firstUrl, secondUrl: secondUrl, firstButtonTitle: TextConstants.faceImageNope, secondButtonTitle: TextConstants.ok, firstAction: { (vc) in
            vc.close()
        }) { (vc) in
            vc.close(completion: completion)
        }
        
        RouterVC().presentViewController(controller: vc)
    }
    
    override func showBack() {
        RouterVC().popViewController()
    }
}

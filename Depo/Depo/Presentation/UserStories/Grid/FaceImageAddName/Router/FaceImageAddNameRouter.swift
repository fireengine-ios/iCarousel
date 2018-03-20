//
//  FaceImageAddNameRouter.swift
//  Depo
//
//  Created by Harhun Brothers on 07.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class FaceImageAddNameRouter: BaseFilesGreedRouter {
    
    override func showBack() {
        RouterVC().popViewController()
    }

}

// MARK: - FaceImageAddNameRouterInput

extension FaceImageAddNameRouter: FaceImageAddNameRouterInput {
    
    func showMerge(firstUrl: URL, secondUrl: URL, completion: @escaping VoidHandler) {
        let vc = PopUpController.with(title: TextConstants.faceImageCheckTheSamePerson, message: TextConstants.faceImageWillMergedTogether, image: .success, firstButtonTitle: TextConstants.faceImageNope, secondButtonTitle: TextConstants.faceImageYes, firstUrl: firstUrl, secondUrl: secondUrl, secondAction: { vc in
            vc.close(completion: completion)
        })
        
        RouterVC().presentViewController(controller: vc)
    }
    
    func popToPeopleItems() {
        for vc in (RouterVC().navigationController?.viewControllers ?? []) {
            if vc is FaceImageItemsViewController {
                RouterVC().popToViewController(vc)
                break
            }
        }
    }

}

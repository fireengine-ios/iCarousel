//
//  CreateStoryPreviewCreateStoryPreviewRouter.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPreviewRouter {
    weak var view: UIViewController?
}

// MARK: CreateStoryPreviewRouterInput
extension CreateStoryPreviewRouter: CreateStoryPreviewRouterInput {
    
    func goToMain() {
        let router = RouterVC()
        
        router.popCreateStory()
    }
    
    func presentFinishPopUp(image: PopUpImage,
                            title: String,
                            storyName: String,
                            titleDesign: DesignText,
                            message: String,
                            messageDesign: DesignText,
                            buttonTitle: String,
                            buttonAction: @escaping VoidHandler) {
        
        
        let popUp = CreateStoryPopUp.with(image: image.image,
                                          title: title,
                                          titleDesign: titleDesign,
                                          message: message,
                                          messageDesign: messageDesign,
                                          buttonTitle: buttonTitle,
                                          buttonAction: buttonAction)
        
        popUp.modalPresentationStyle = .overFullScreen
        view?.navigationController?.present(popUp, animated: false, completion: nil)
    }
}

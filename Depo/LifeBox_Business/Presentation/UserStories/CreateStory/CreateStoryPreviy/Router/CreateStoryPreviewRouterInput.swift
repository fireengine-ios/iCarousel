//
//  CreateStoryPreviewCreateStoryPreviewRouterInput.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryPreviewRouterInput {
    func goToMain()
    func presentFinishPopUp(image: PopUpImage,
                            title: String,
                            storyName: String,
                            titleDesign: DesignText,
                            message: String,
                            messageDesign: DesignText,
                            buttonTitle: String,
                            buttonAction: @escaping VoidHandler)
}

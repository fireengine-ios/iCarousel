//
//  CreateStoryPreviewViewIO.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryPreviewViewInput: class {
    func startShowVideoFromResponce(responce: CreateStoryResponce)
    func prepareToDismiss()
}

protocol CreateStoryPreviewViewOutput: class {
    func viewIsReady()
    func onSaveStory()
}

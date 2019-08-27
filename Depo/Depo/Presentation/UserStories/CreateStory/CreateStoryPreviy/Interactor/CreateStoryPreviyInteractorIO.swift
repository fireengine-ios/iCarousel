//
//  CreateStoryPreviewInteractorIO.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryPreviewInteractorInput: class {
    var story: PhotoStory? { get }
    
    func viewIsReady()
    func onSaveStory()
}

protocol CreateStoryPreviewInteractorOutput: class {
    func startShowVideoFromResponse(response: CreateStoryResponse)
    func storyCreated()
    func storyCreatedWithError()
}

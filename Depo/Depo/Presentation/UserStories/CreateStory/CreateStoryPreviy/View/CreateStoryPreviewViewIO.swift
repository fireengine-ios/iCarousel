//
//  CreateStoryPreviewViewIO.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryPreviewViewInput: AnyObject {
    func startShowVideoFromResponse(response: CreateStoryResponse)
    func prepareToDismiss()
}

protocol CreateStoryPreviewViewOutput: AnyObject {
    func viewIsReady()
    func onSaveStory()
    func getStoryName() -> String
}

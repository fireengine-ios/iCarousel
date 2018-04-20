//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderInteractorInput.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryPhotosOrderInteractorInput {
    func viewIsReady()
    func onNextButton(array: [Item])
    func onMusicSelection()
}

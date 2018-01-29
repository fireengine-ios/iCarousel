//
//  CreateStoryNameCreateStoryNameInteractorInput.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryNameInteractorInput {
    var needSelectionItems: Bool { set get }
    func onCreateStory(storyName: String)
    func onCreateStory(storyName: String, items: [BaseDataSourceItem])
}

//
//  CreateStoryNameCreateStoryNameInteractorInput.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryNameInteractorInput {
    
    var needSelectionItems: Bool { get set }
    var isFavorites: Bool { get set }
    
    func onCreateStory(storyName: String)
    func onCreateStory(storyName: String, items: [BaseDataSourceItem])
    
    func trackScreen()
    func trackStoryNameGiven()
}

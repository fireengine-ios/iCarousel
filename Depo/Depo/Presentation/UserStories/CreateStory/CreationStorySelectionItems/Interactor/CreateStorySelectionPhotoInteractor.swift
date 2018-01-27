//
//  CreateStorySelectionPhotoInteractor.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 26/01/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class CreateStorySelectionPhotoInteractor: CreateStorySelectionInteractor {

    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        guard let story = photoStory else {
            return
        }
        if story.storyPhotos.isEmpty {
            super.reloadItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
        } else {
            output.getContentWithSuccess(array: [story.storyPhotos])
        }
    }
    
    override func nextItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        guard let story = photoStory else {
            return
        }
        if story.storyPhotos.isEmpty {
            super.nextItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
        }
    }
}

//
//  CreateStorySelectionInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 02.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol CreateStorySelectionInteractorOutput: class {
    
    func configurateWithPhotoStory(story: PhotoStory)
    
    func getContentWithSuccess(array: [[BaseDataSourceItem]])
    
}

//
//  StoriesInteractor.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikov on 15.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class StoriesInteractor: BaseFilesGreedInteractor {

    override func getAllItems(sortBy: SortedRules) {
        log.debug("StoriesInteractor getAllItems")
        
        guard let remote = remoteItems as? StoryService else {
            return
        }
        remote.allStories(sortBy: sortBy.sortingRules, sortOrder: sortBy.sortOder, success: { [weak self] stories in
            log.debug("StoriesInteractor getAllItems StoryService allStories success")
            
            DispatchQueue.toMain {
                var array = [[BaseDataSourceItem]]()
                array.append(stories)
                self?.output.getContentWithSuccess(array: array)
            }
            }, fail: { [weak self] in
                log.debug("StoriesInteractor getAllItems StoryService allStories fail")
                
                DispatchQueue.toMain {
                    self?.output.asyncOperationFail(errorMessage: "fail")
                }
        })
    }
    
}

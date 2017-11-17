//
//  CreateStoryNameCreateStoryNameViewOutput.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol CreateStoryNameViewOutput {

    /**
        @author Oleg
        Notify presenter that view is ready
    */

    func viewIsReady()
    
    func onCreateStory(storyName: String?)
    
    var items: [BaseDataSourceItem]? { get set }
}

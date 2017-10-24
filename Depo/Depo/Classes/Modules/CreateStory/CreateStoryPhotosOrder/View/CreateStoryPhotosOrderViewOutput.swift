//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderViewOutput.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol CreateStoryPhotosOrderViewOutput {

    /**
        @author Oleg
        Notify presenter that view is ready
    */

    func viewIsReady()
    
    func onNextButton(array: [Item])
    
    func onMusicSelection()
    
}

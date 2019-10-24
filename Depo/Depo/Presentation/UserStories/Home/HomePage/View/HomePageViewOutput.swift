//
//  HomePageHomePageViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol HomePageViewOutput {

    func viewIsReady()
    
    func viewWillAppear()
    
    func viewIsReadyForPopUps()

    func showSettings()
    
    func showSearch(output: UIViewController?)
    
    func onSyncContacts()
    
    func allFilesPressed()
    
    func favoritesPressed()
    
    func createStory()
    
    func needRefresh()
    
    func shownSpotlight(type: SpotlightType)
    
    func closedSpotlight(type: SpotlightType)
    
    func requestShowSpotlight(for types: [SpotlightType])
    
    func giftButtonPressed()
    
}

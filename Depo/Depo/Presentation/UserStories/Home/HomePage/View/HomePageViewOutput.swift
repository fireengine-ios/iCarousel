//
//  HomePageHomePageViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol HomePageViewOutput {

    func viewIsReady()
    
    func homePagePresented()
    
    func showSettings()
    
    func showSearch(output: UIViewController?)
    
    func onSyncContacts()
    
    func allFilesPressed()
    
    func favoritesPressed()
    
    func createStory()
    
    func needRefresh()
}

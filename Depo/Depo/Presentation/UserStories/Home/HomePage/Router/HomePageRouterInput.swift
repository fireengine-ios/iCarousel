//
//  HomePageHomePageRouterInput.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol HomePageRouterInput {
    
    func moveToSettingsScreen()
    
    func moveToSearchScreen(output: UIViewController?)
    
    func moveToSyncContacts()
    
    func moveToAllFilesPage()
    
    func moveToFavouritsFilesPage()
    
    func moveToCreationStory()
    
    func showError(errorMessage: String)
    
    func showPopupForNewUser(with message: String, title: String, headerTitle: String)

}

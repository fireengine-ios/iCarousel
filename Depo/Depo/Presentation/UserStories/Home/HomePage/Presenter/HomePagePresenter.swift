//
//  HomePageHomePagePresenter.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class HomePagePresenter: HomePageModuleInput, HomePageViewOutput, HomePageInteractorOutput, BaseFilesGreedModuleOutput {
    
    weak var view: HomePageViewInput!
    var interactor: HomePageInteractorInput!
    var router: HomePageRouterInput!

    private(set) var viewType = MoreActionsConfig.ViewType.Grid
    private(set) var sortType = MoreActionsConfig.SortRullesType.TimeNewOld
    
    func viewIsReady() {
        view.setupInitialState()
    }
    
    func homePagePresented(){
        interactor.homePagePresented()
    }
    
    func showSettings() {
        router.moveToSettingsScreen()
    }
    
    func onSyncContacts(){
        router.moveToSyncContacts()
    }
    
    func allFilesPressed() {
        router.moveToAllFilesPage()
    }
    
    func favoritesPressed() {
        router.moveToFavouritsFilesPage()
    }
    
    func createStory() {
        router.moveToCreationStory()
    }
    
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType) {
        self.viewType = type
        self.sortType = sortedType
    }
    
}

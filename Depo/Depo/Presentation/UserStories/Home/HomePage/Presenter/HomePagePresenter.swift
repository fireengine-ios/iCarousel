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

    private(set) var allFilesViewType = MoreActionsConfig.ViewType.Grid
    private(set) var allFilesSortType = MoreActionsConfig.SortRullesType.TimeNewOld
    
    private(set) var favoritesViewType = MoreActionsConfig.ViewType.Grid
    private(set) var favoritesSortType = MoreActionsConfig.SortRullesType.TimeNewOld
    
    func viewIsReady() {
        
    }
    
    func homePagePresented() {
        interactor.homePagePresented()
    }
    
    func showSettings() {
        router.moveToSettingsScreen()
    }
    
    func showSearch(output: UIViewController?) {
        router.moveToSearchScreen(output: output)
    }
    
    func onSyncContacts() {
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
    
    func needRefresh() {
        interactor.needRefresh()
    }
    
    func stopRefresh() {
        view.stopRefresh()
    }
    
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType, fieldType: FieldValue) {
        if fieldType == .all {
            self.allFilesViewType = type
            self.allFilesSortType = sortedType
        } else if fieldType == .favorite {
            self.favoritesViewType = type
            self.favoritesSortType = sortedType
        }
    }
    
}

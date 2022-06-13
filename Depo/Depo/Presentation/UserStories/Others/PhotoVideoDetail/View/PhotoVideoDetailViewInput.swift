//
//  PhotoVideoDetailPhotoVideoDetailViewInput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoVideoDetailViewInput: AnyObject, ActivityIndicator, ErrorPresenter {
    
    var status: ItemStatus { get set }
    
    var bottomDetailViewManager: BottomDetailViewAnimationManagerProtocol? { get }
    
    func setupInitialState()
    
    func onShowSelectedItem(at index: Int, from items: [Item])
    
    func updateItems(objectsArray: [Item], selectedIndex: Int)
    
    func appendItems(_ items: [Item])
    
    func onLastRemoved()
    
    func getNavigationController() -> UINavigationController?
    
    func onItemSelected(at index: Int, from items: [Item])
    
    func hideView()
    
    func show(name: String)

    func showDescription(description: String)
    
    func showValidateNameSuccess(name: String)

    func showValidateDescriptionSuccess(description: String)
    
    func updatePeople(items: [PeopleOnPhotoItemResponse])
    
    func setHiddenPeoplePlaceholder(isHidden: Bool)
    
    func setHiddenPremiumStackView(isHidden: Bool)
    
    func closeDetailViewIfNeeded()
    
    func showBottomDetailView()
    
    func updateBottomDetailView()
    
    func deleteShareInfo()
    
    func updateExpiredItem(_ item: WrapData)
    
    func updateItem(_ item: WrapData)

    func printSelected()

    @available(iOS 13.0, *)
    var activityItemsConfiguration: UIActivityItemsConfigurationReading? { get set }

    func removeTextSelectionInteractionFromCurrentCell()
}

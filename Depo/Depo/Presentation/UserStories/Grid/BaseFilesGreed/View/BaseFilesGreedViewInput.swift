//
//  BaseFilesGreedViewInput.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol BaseFilesGreedViewInput: class {

    func setupInitialState()
    
    func showCustomPopUpWithInformationAboutAccessToMediaLibrary()
    
    func getCollectionViewWidth() -> CGFloat
    
    func stopRefresher()
    
    func setCollectionViewVisibilityStatus(visibilityStatus: Bool)
    
    func startSelection(with numberOfItems: Int)
    
    func stopSelection()
    
    func getFolder() -> Item?

    func changeSortingRepresentation(sortType type: SortedRules)
    
    func selectedItemsCountChange(with count: Int)
    
    func setupUnderNavBarBar(withConfig config: GridListTopBarConfig)
    
    func setThreeDotsMenu(active isActive: Bool)
    
    func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String)
    
    func showNoFilesTop()
    
    func hideNoFiles()
}

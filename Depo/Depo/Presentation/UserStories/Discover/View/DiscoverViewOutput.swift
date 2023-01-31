//
//  DiscoverViewOutput.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol DiscoverViewOutput: AnyObject {
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

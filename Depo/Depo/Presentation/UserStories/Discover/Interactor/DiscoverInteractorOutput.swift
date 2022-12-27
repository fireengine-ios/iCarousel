//
//  DiscoverInteractorOutput.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol DiscoverInteractorOutput: AnyObject {
//    func stopRefresh()
//    func didObtainHomeCards(_ cards: [HomeCardResponse])
//    func didObtainError(with text: String, isNeedStopRefresh: Bool)
//    func fillTableView(isReloadAll: Bool)
//    func showSpinner()
//    func hideSpinner()
//    func showSnackBarWith(message: String)
    
    func didFinishedAllRequests()
    func didObtainHomeCards(_ cards: [HomeCardResponse])
    func didObtainError(with text: String, isNeedStopRefresh: Bool)
    func stopRefresh()
}

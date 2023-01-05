//
//  DiscoverPresenter.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class DiscoverPresenter: BasePresenter, DiscoverModuleInput {
    weak var view: DiscoverViewInput!
    var interactor: DiscoverInteractorInput!
    var router: DiscoverRouterInput!
    private lazy var placesData: [WrapData] = []
    private var cards: [HomeCardResponse] = []
    
    func viewIsReady() {
        interactor.viewIsReady()
        view.showSpinner()
    }
}

extension DiscoverPresenter: DiscoverInteractorOutput {
    func didFinishedAllRequests() {
        view.hideSpinner()
        view.didFinishedAllRequests()
    }
    
    func didObtainHomeCards(_ cards: [HomeCardResponse]) {
        self.cards = cards
    }
    
    func stopRefresh() {
        view.stopRefresh()
    }
    
    func didObtainError(with text: String, isNeedStopRefresh: Bool) {
        if isNeedStopRefresh {
            stopRefresh()
        }
    }
}

extension DiscoverPresenter: DiscoverViewOutput {
    
    func getModelCards() -> Any? {
//        cards.filter{
//            guard let details = $0.details?["thumbnail"],
//                  let urlStr = details as? String,
//                  !urlStr.isEmpty else { return false }
//
//            return true
//        }
        cards
    }
    
    func navigate(for view: HomeCardTypes) {
        router.navigate(for: view)
    }
}

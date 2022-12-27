//
//  DiscoverInteractor.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class DiscoverInteractor {
    weak var output: DiscoverInteractorOutput!
    private lazy var placesService = PlacesService()
    private lazy var homeCardsService: HomeCardsService = factory.resolve()
    let group = DispatchGroup()
    
    private func getAllCardsForHomePage() {
        group.enter()
        homeCardsService.all { [weak self] result in
            DispatchQueue.main.async {
                self?.output.stopRefresh()
                switch result {
                case .success(let response):
                    self?.group.leave()
                    self?.output.didObtainHomeCards(response)
                case .failed(let error):
                    self?.group.leave()
                    DispatchQueue.toMain {
                        self?.output.didObtainError(with: error.description, isNeedStopRefresh: true)
                    }
                }
            }
        }
    }
    
}

extension DiscoverInteractor: DiscoverInteractorInput {
    func viewIsReady() {
        getAllCardsForHomePage()
        group.notify(queue: .main) {
            self.output?.didFinishedAllRequests()
        }
    }
}

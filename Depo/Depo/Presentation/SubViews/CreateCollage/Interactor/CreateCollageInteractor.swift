//
//  CreateCollageInteractor.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class CreateCollageInteractor {
    
    weak var output: CreateCollageInteractorOutput!
    private lazy var service = ForYouService()
    let group = DispatchGroup()
    
    private func getCollageTemplate() {
        debugLog("ForYou getCollageTemplate")
        group.enter()

        service.forYouCollageTemplate() { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let response):
                self?.output.getCollageTemplate(data: response)
            case .failed(let error):
                debugLog("ForYou Error getCollageTemplate")
                break
            }
        }
    }
}

extension CreateCollageInteractor: CreateCollageInteractorInput {
    func viewIsReady() {
        getCollageTemplate()
        
        group.notify(queue: .main) {
            self.output?.didFinishedAllRequests()
        }
    }
}


//
//  PremiumInteractor.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PremiumInteractor {
    
    weak var output: PremiumInteractorOutput!
    
}

// MARK: PremiumInteractorInput
extension PremiumInteractor: PremiumInteractorInput {

    func startPurchaseBecomePremiumUser() {
        let authorityStorage: AuthorityStorage = factory.resolve()
        authorityStorage.refrashStatus(premium: true, dublicates: true, faces: true)

        output.didPurchased()
    }
}

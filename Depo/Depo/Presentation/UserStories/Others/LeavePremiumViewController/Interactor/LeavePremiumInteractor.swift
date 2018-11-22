//
//  LeavePremiumInteractor.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class LeavePremiumInteractor {
    
    weak var output: LeavePremiumInteractorOutput!
    
    private let accountService: AccountServicePrl
    
    init(accountService: AccountServicePrl = AccountService()) {
        self.accountService = accountService
    }
    
}

// MARK: LeavePremiumInteractorInput
extension LeavePremiumInteractor: LeavePremiumInteractorInput {
    
    func getAccountType() {
        accountService.info(
            success: { [weak self] response in
                guard let response = response as? AccountInfoResponse,
                    let accountType = response.accountType else { return }
                DispatchQueue.main.async {
                    self?.output.didLoadAccountType(accountTypeString: accountType)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.didErrorMessage(with: errorResponse.description)
                }
        })
    }
    
}

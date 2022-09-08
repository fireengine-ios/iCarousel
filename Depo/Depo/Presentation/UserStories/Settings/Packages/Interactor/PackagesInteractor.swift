//
//  PackagesPackagesInteractor.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PackagesInteractor {
    weak var output: PackagesInteractorOutput!
    private let accountService: AccountServicePrl

    init(accountService: AccountServicePrl = AccountService()) {
        self.accountService = accountService
    }
}

// MARK: PackagesInteractorInput
extension PackagesInteractor: PackagesInteractorInput {
    func getUserAuthority() {
        accountService.permissions { [weak self] (result) in
            switch result {
            case .success(let response):
                AuthoritySingleton.shared.refreshStatus(with: response)
                DispatchQueue.main.async {
                    self?.output.successedGotUserAuthority()
                }
            case .failed(let error):
                DispatchQueue.main.async {
                    self?.output.failed(with: error.description)
                }
            }
        }
    }
    
    func getQuotaInfo() {
        AccountService().quotaInfo(success: { [weak self] response in
            guard let response = response as? QuotaInfoResponse else {
                return
            }
            
            DispatchQueue.main.async {
                self?.output.setQuotaInfo(quotoInfo: response)
            }
        }, fail: { error in
            assertionFailure("Тo data received for quotaInfo request \(error.localizedDescription) ")
        })
    }
}

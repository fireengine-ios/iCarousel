//
//  PackagesPackagesPresenter.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PackagesPresenter {
    weak var view: PackagesViewInput?
    var interactor: PackagesInteractorInput!
    var router: PackagesRouterInput!
    
    private var quotaInfo: QuotaInfoResponse?
    private var accountType = AccountType.all
    private var percentage: CGFloat = 0
    
    func tuneUpQuota(quotaInfo: QuotaInfoResponse?) {
        if let quota = quotaInfo{
            self.quotaInfo = quota
        }
    }
}

// MARK: PackagesViewOutput
extension PackagesPresenter: PackagesViewOutput {
    func viewIsReady() {
        view?.startActivityIndicator()
        interactor.getQuotaInfo()
    }
    
    func viewWillAppear() {
        view?.startActivityIndicator()
        interactor.getUserAuthority()
    }

    func configureCard(_ card: PackageInfoView) {
        card.delegate = self
    }
}

// MARK: PackagesInteractorOutput
extension PackagesPresenter: PackagesInteractorOutput {
    func setQuotaInfo(quotoInfo: QuotaInfoResponse) {
        view?.stopActivityIndicator()

        self.quotaInfo = quotoInfo
        setMemoryPercentage()
    }
    
    func setMemoryPercentage() {
        if let used = quotaInfo?.bytesUsed, let total = quotaInfo?.bytes {
            percentage = 100 * CGFloat(used) / CGFloat(total)
            view?.setupStackView(with: percentage)
        }
    }

    func successedGotUserAuthority() {
        view?.stopActivityIndicator()
        view?.setupStackView(with: percentage)
    }

    func failed(with errorMessage: String) {
        view?.stopActivityIndicator()
    }
}

//// MARK: PackageInfoViewDelegate
extension PackagesPresenter: PackageInfoViewDelegate {
    func onSeeDetailsTap(with type: ControlPackageType) {
        switch type {
        case .usage:
            router.openUsage()
        case .myStorage:
            let usage = UsageResponse()
            usage.usedBytes = quotaInfo?.bytesUsed
            usage.quotaBytes = quotaInfo?.bytes
            router.openMyStorage(usageStorage: usage)
        case .myProfile:
            guard let userInfo = SingletonStorage.shared.accountInfo else {
                let error = CustomErrors.text("Unexpected found nil while getting user info. Refresh page may solve this problem.")
                failed(with: error.localizedDescription)
                return
            }
            let isTurkcell = SingletonStorage.shared.isTurkcellUser
            router.openUserProfile(userInfo: userInfo, isTurkcellUser: isTurkcell)
            break
        case .accountType:
            assertionFailure()
        }
    }
}

// MARK: PackagesModuleInput
extension PackagesPresenter: PackagesModuleInput { }

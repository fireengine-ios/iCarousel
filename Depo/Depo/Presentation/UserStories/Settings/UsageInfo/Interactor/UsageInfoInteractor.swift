//
//  UsageInfoInteractor.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class UsageInfoInteractor {
    weak var output: UsageInfoInteractorOutput!
    private let analyticsManager: AnalyticsService = factory.resolve()
    private let accountService: AccountServicePrl

    init(accountService: AccountServicePrl = AccountService()) {
        self.accountService = accountService
    }
}

extension UsageInfoInteractor: UsageInfoInteractorInput {
    func getUsage() {
        accountService.usage(
            success: { [weak self] response in
                guard let usage = response as? UsageResponse else { return }
                DispatchQueue.main.async {
                    self?.output.successed(usage: usage)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: errorResponse)
                }
        })
    }
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.UsageInfoScreen())
        analyticsManager.logScreen(screen: .usageInfo)
        analyticsManager.trackDimentionsEveryClickGA(screen: .usageInfo)
    }
}

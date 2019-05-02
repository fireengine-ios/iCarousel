//
//  FeedbackViewFeedbackViewInteractor.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FeedbackViewInteractor: FeedbackViewInteractorInput {

    weak var output: FeedbackViewInteractorOutput!
    private let analyticsManager: AnalyticsService = factory.resolve()
    func onSend(selectedLanguage: LanguageModel) {
        output.startAsyncOperation()
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .feedbackForm, eventLabel: .feedbackSend)
        getUserInfoString(with: selectedLanguage.displayLanguage ?? "")
    }
    
    func getUserInfoString(with languageName: String) {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var phoneString: String = ""
        var quota: Int64 = 0
        var quotaUsed: Int64 = 0
        var subscriptions: [SubscriptionPlanBaseResponse] = []
        
        SingletonStorage.shared.getAccountInfoForUser(success: { userInfoResponse in
            if let phone = userInfoResponse.phoneNumber {
                phoneString = phone
            }
            group.leave()
        }, fail: { error in
            group.leave()
        })
        
        AccountService().quotaInfo(success: {respoce in
            let quotaInfoResponse = respoce as? QuotaInfoResponse
            quota = quotaInfoResponse?.bytes ?? 0
            quotaUsed = quotaInfoResponse?.bytesUsed ?? 0
            group.leave()
        }) { error in
            group.leave()
        }
        
        SubscriptionsServiceIml().activeSubscriptions(success: { response in
            let subscriptionsResponce = response as? ActiveSubscriptionResponse
            if let array = subscriptionsResponce?.list {
                subscriptions.append(contentsOf: array)
            }
            group.leave()
        }, fail: { error in
            group.leave()
        })
        
        group.notify(queue: .main) {[weak self] in
            let versionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
            var packages = ""
            if subscriptions.count > 0 {
                packages = subscriptions
                .flatMap { $0.subscriptionPlanDisplayName }
                .joined(separator: ", ")
            }
            let userInfoString = String(format: TextConstants.feedbackMailTextFormat, versionString, phoneString, CoreTelephonyService().operatorName() ?? "", UIDevice.current.model, UIDevice.current.systemVersion, Device.locale, languageName, ReachabilityService.shared.isReachableViaWiFi ? "WIFI" : "WWAN", quota, quotaUsed, packages)
            
            self?.output.asyncOperationSuccess()
            self?.output.languageRequestSended(text: userInfoString)
        }

    }
    
    func trackScreen() {
        analyticsManager.logScreen(screen: .contactUS)
        analyticsManager.trackDimentionsEveryClickGA(screen: .contactUS)
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .feedbackForm, eventLabel: .feedbackOpen)
    }

}

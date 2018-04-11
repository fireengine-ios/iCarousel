//
//  FeedbackViewFeedbackViewInteractor.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FeedbackViewInteractor: FeedbackViewInteractorInput {

    weak var output: FeedbackViewInteractorOutput!
        
    func onSend(selectedLanguage: LanguageModel) {
        output.startAsyncOperation()
        
        let parameter = SelectedLanguage(selectedLanguage: selectedLanguage)
        FeedbackService().sendSelectedLanguage(selectedLanguageParameter: parameter, succes: {[weak self] success in
            DispatchQueue.main.async {
                self?.getUserInfoString(with: selectedLanguage.displayLanguage ?? "")
            }
            }, fail: { [weak self] fail in
                DispatchQueue.main.async {
                    self?.output.fail(text: fail.description)
                }
        })
        
    }
    
    func getUserInfoString(with languageName: String) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: DispatchQueueLabels.getUserInfo)
        group.enter()
        group.enter()
        group.enter()
        
        var phoneString: String = ""
        var quota: Int64 = 0
        var quotaUsed: Int64 = 0
        var subscriptions: [SubscriptionPlanBaseResponse] = []
        
        AccountService().info(success: {responce in
            let userInfoResponse = responce as? AccountInfoResponse
            if let phone = userInfoResponse?.phoneNumber {
                phoneString = phone
            }
            group.leave()
        }) { error in
            group.leave()
        }
        
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
        
        group.notify(queue: queue) {[weak self] in
            DispatchQueue.main.async {
                let versionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
                let packages = subscriptions
                    .flatMap { $0.subscriptionPlanDisplayName }
                    .joined(separator: ", ")
                let userInfoString = String(format: TextConstants.feedbackMailTextFormat, versionString, phoneString, CoreTelephonyService().operatorName() ?? "", UIDevice.current.model, UIDevice.current.systemVersion, Device.locale, languageName, ReachabilityService().isReachableViaWiFi ? "WIFI" : "WWAN", quota, quotaUsed, packages)
                
                self?.output.asyncOperationSucces()
                self?.output.languageRequestSended(text: userInfoString)
            }
        }

    }

}

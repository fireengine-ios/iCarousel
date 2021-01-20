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
    private lazy var accountService = AccountService()
    
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
        group.enter()
        
        var phoneString = ""
        var quota: Int64 = 0
        var quotaUsed: Int64 = 0
        var email = TextConstants.NotLocalized.feedbackEmail
        
        SingletonStorage.shared.getAccountInfoForUser(success: { userInfoResponse in
//            if let phone = userInfoResponse.phoneNumber {
//                phoneString = phone
//            }
            group.leave()
        }, fail: { error in
            group.leave()
        })
        
        accountService.quotaInfo(success: { response in
            let quotaInfoResponse = response as? QuotaInfoResponse
            quota = quotaInfoResponse?.bytes ?? 0
            quotaUsed = quotaInfoResponse?.bytesUsed ?? 0
            group.leave()
        }, fail: { error in
            group.leave()
        })
        
        accountService.feedbackEmail { response in
            switch response {
            case .success(let feedbackResponse):
                if let value = feedbackResponse.value {
                    email = value
                }
                group.leave()
            case .failed(_):
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            let versionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
            let userInfoString = String(format: TextConstants.feedbackMailTextFormat, versionString, phoneString, CoreTelephonyService().operatorName() ?? "", UIDevice.current.modelName, UIDevice.current.systemVersion, Device.locale, languageName, ReachabilityService.shared.isReachableViaWiFi ? "WIFI" : "WWAN", quota, quotaUsed, "")
            
            self?.output.asyncOperationSuccess()
            self?.output.languageRequestSended(email: email, text: userInfoString)
        }
    }
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ContactUsScreen())
        analyticsManager.logScreen(screen: .contactUS)
        analyticsManager.trackDimentionsEveryClickGA(screen: .contactUS)
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .feedbackForm, eventLabel: .feedbackOpen)
    }

}

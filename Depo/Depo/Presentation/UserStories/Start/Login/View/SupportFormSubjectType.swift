//
//  SupportFormSubjectType.swift
//  Depo
//
//  Created by Darya Kuliashova on 9/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol SupportFormSubjectTypeProtocol {
    var localizedSubject: String { get }
    var localizedTitle: String { get }
    var localizedInfoHtml: String { get }
    func googleAnalyticsEventLabel(isSupportForm: Bool) -> GAEventLabel
}

enum SupportFormScreenType {
    case login
    case signup
    
    var subjects: [SupportFormSubjectTypeProtocol] {
        switch self {
        case .login:
            return SupportFormSubjectTypeLogin.allCases
        case .signup:
            return SupportFormSubjectTypeSignup.allCases
        }
    }
    
    var googleAnalyticsEventAction: GAEventAction {
        switch self {
        case .login:
            return .supportLogin
        case .signup:
            return .supportSignUp
        }
    }
}

private enum SupportFormSubjectTypeLogin: SupportFormSubjectTypeProtocol, CaseIterable {
    case subject1
    case subject2
    case subject3
    case subject4
    case subject5
    case subject6
    case subject7
    
    var localizedSubject: String {
        switch self {
        case .subject1: return TextConstants.onLoginSupportFormSubject1
        case .subject2: return TextConstants.onLoginSupportFormSubject2
        case .subject3: return TextConstants.onLoginSupportFormSubject3
        case .subject4: return TextConstants.onLoginSupportFormSubject4
        case .subject5: return TextConstants.onLoginSupportFormSubject5
        case .subject6: return TextConstants.onLoginSupportFormSubject6
        case .subject7: return TextConstants.onLoginSupportFormSubject7
        }
    }
    
    var localizedTitle: String {
        switch self {
        case .subject1: return TextConstants.onLoginSupportFormSubject1InfoLabel
        case .subject2: return TextConstants.onLoginSupportFormSubject2InfoLabel
        case .subject3: return TextConstants.onLoginSupportFormSubject3InfoLabel
        case .subject4: return TextConstants.onLoginSupportFormSubject4InfoLabel
        case .subject5: return TextConstants.onLoginSupportFormSubject5InfoLabel
        case .subject6: return TextConstants.onLoginSupportFormSubject6InfoLabel
        case .subject7: return TextConstants.onLoginSupportFormSubject7InfoLabel
        }
    }
    
    var localizedInfoHtml: String {
        let infoText: String
        
        switch self {
        case .subject1: infoText = TextConstants.onLoginSupportFormSubject1DetailedInfoText
        case .subject2: infoText = TextConstants.onLoginSupportFormSubject2DetailedInfoText
        case .subject3: infoText = TextConstants.onLoginSupportFormSubject3DetailedInfoText
        case .subject4: infoText = TextConstants.onLoginSupportFormSubject4DetailedInfoText
        case .subject5: infoText = TextConstants.onLoginSupportFormSubject5DetailedInfoText
        case .subject6: infoText = TextConstants.onLoginSupportFormSubject6DetailedInfoText
        case .subject7: infoText = TextConstants.onLoginSupportFormSubject7DetailedInfoText
        }
        
        return String(format: infoText, Device.locale)
    }
    
    func googleAnalyticsEventLabel(isSupportForm: Bool) -> GAEventLabel {
        switch self {
        case .subject1: return .supportLoginForm(.subject1, isSupportForm: isSupportForm)
        case .subject2: return .supportLoginForm(.subject2, isSupportForm: isSupportForm)
        case .subject3: return .supportLoginForm(.subject3, isSupportForm: isSupportForm)
        case .subject4: return .supportLoginForm(.subject4, isSupportForm: isSupportForm)
        case .subject5: return .supportLoginForm(.subject5, isSupportForm: isSupportForm)
        case .subject6: return .supportLoginForm(.subject6, isSupportForm: isSupportForm)
        case .subject7: return .supportLoginForm(.subject7, isSupportForm: isSupportForm)
        }
    }
}

private enum SupportFormSubjectTypeSignup: SupportFormSubjectTypeProtocol, CaseIterable {
    case subject1
    case subject2
    case subject3
    
    var localizedSubject: String {
        switch self {
        case .subject1: return TextConstants.onSignupSupportFormSubject1
        case .subject2: return TextConstants.onSignupSupportFormSubject2
        case .subject3: return TextConstants.onSignupSupportFormSubject3
        }
    }
    
    var localizedTitle: String {
        switch self {
        case .subject1: return TextConstants.onSignupSupportFormSubject1InfoLabel
        case .subject2: return TextConstants.onSignupSupportFormSubject2InfoLabel
        case .subject3: return TextConstants.onSignupSupportFormSubject3InfoLabel
        }
    }
    
    var localizedInfoHtml: String {
        let infoText: String
        
        switch self {
        case .subject1: infoText = TextConstants.onSignupSupportFormSubject1DetailedInfoText
        case .subject2: infoText = TextConstants.onSignupSupportFormSubject2DetailedInfoText
        case .subject3: infoText = TextConstants.onSignupSupportFormSubject3DetailedInfoText
        }
        
        return String(format: infoText, Device.locale)
    }

    func googleAnalyticsEventLabel(isSupportForm: Bool) -> GAEventLabel {
        switch self {
        case .subject1: return .supportSignUpForm(.subject1, isSupportForm: isSupportForm)
        case .subject2: return .supportSignUpForm(.subject2, isSupportForm: isSupportForm)
        case .subject3: return .supportSignUpForm(.subject3, isSupportForm: isSupportForm)
        }
    }
}

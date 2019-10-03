//
//  SupportFormSubjectType.swift
//  Depo
//
//  Created by Darya Kuliashova on 9/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

enum SupportFormSubjectType: Int, CaseIterable {
    case subject1
    case subject2
    case subject3
    case subject4
    case subject5
    case subject6
    case subject7
    
    var localizedSubject: String {
        switch self {
        case .subject1: return TextConstants.supportFormSubject1
        case .subject2: return TextConstants.supportFormSubject2
        case .subject3: return TextConstants.supportFormSubject3
        case .subject4: return TextConstants.supportFormSubject4
        case .subject5: return TextConstants.supportFormSubject5
        case .subject6: return TextConstants.supportFormSubject6
        case .subject7: return TextConstants.supportFormSubject7
        }
    }
    
    var localizedTitle: String {
        switch self {
        case .subject1: return TextConstants.supportFormSubject1InfoLabel
        case .subject2: return TextConstants.supportFormSubject2InfoLabel
        case .subject3: return TextConstants.supportFormSubject3InfoLabel
        case .subject4: return TextConstants.supportFormSubject4InfoLabel
        case .subject5: return TextConstants.supportFormSubject5InfoLabel
        case .subject6: return TextConstants.supportFormSubject6InfoLabel
        case .subject7: return TextConstants.supportFormSubject7InfoLabel
        }
    }
    
    var localizedInfoHtml: String {
        let infoText: String
        
        switch self {
        case .subject1: infoText = TextConstants.supportFormSubject1DetailedInfoText
        case .subject2: infoText = TextConstants.supportFormSubject2DetailedInfoText
        case .subject3: infoText = TextConstants.supportFormSubject3DetailedInfoText
        case .subject4: infoText = TextConstants.supportFormSubject4DetailedInfoText
        case .subject5: infoText = TextConstants.supportFormSubject5DetailedInfoText
        case .subject6: infoText = TextConstants.supportFormSubject6DetailedInfoText
        case .subject7: infoText = TextConstants.supportFormSubject7DetailedInfoText
        }
        
        return String(format: infoText, Device.locale)
    }
}

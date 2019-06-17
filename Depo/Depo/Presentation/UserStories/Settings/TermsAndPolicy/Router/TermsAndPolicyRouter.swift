//
//  TermsAndPolicyRouter.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class TermsAndPolicyRouter {
    private let router = RouterVC()
    private let eulaService = EulaService()
}

extension TermsAndPolicyRouter: TermsAndPolicyRouterInput {
   
    func closeTermsAndPolicy() {
        router.popViewController()
    }
    
    func goToTermsOfUse() {
        eulaService.getTermOfUse { [weak self] response in
            switch response {
            case .success(let text):
                
                let newViewController = TermsDescriptionTextView(text: text.contentOut.htmlToAttributedString!)
                self?.router.pushViewController(viewController: newViewController)
            case .failed(_):
                print("failed")
            }
        }
    }
    
    func goToPrivacyPolicy() {
        let newViewController = PrivacyPolicyWebView()
        router.pushViewController(viewController: newViewController)
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

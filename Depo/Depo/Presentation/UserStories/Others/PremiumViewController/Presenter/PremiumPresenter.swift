//
//  PremiumPresenter.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PremiumPresenter {
    
    weak var view: PremiumViewInput!
    var interactor: PremiumInteractorInput!
    var router: PremiumRouterInput!
    
    var title: String
    var headerTitle: String
    
    init(title: String, headerTitle: String) {
        self.title = title
        self.headerTitle = headerTitle
    }
    
}

// MARK: - PremiumViewOutput
extension PremiumPresenter: PremiumViewOutput {
    
    func onViewDidLoad(with premiumView: PremiumView) {
        premiumView.delegate = self
    }
    
}

// MARK: - PremiumInteractorOtuput
extension PremiumPresenter: PremiumInteractorOutput {
    
}

// MARK: - PremiumViewDelegate
extension PremiumPresenter: PremiumViewDelegate {
    
    func onBecomePremiumTap() {
    }
    
}

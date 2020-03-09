//
//  MobilePaymentPermissionViewController.swift
//  Depo
//
//  Created by YAGIZHAN AKDUMAN on 21.02.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class MobilePaymentPermissionViewController: ViewController, NibInit, ControlTabBarProtocol {
    
    weak var delegate: MobilePaymentPermissionProtocol?
    var urlString: String?
    private var isChecked: Bool = false
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    // MARK: Life Cycle
    
    override func loadView() {
        let mainView = MobilePaymentPermissionView.initFromNib()
        mainView.controller = self
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        analyticsService.logScreen(screen: .mobilePaymentExplanation)
    }
    
    private func setupNavigation() {
        hideTabBar()
        navigationBarWithGradientStyle()
        let backButton = UIBarButtonItem(title: TextConstants.backTitle, target: self, selector: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        guard let url = urlString else {
            return
        }
        delegate?.backTapped(url: url)
        trackGAEvent(eventLabel: .backWithCheck(isChecked))
    }
    
}

// MARK: Mobile Payment Permission View Delegate
extension MobilePaymentPermissionViewController: MobilePaymentPermissionViewInput {
    
    func checkBoxDidChange(isChecked: Bool) {
        self.isChecked = isChecked
    }
    
    func linkTapped() {
        guard let urlstring = urlString else {
            return
        }
        let viewController = WebViewController(urlString: urlstring)
        RouterVC().pushViewController(viewController: viewController)
        analyticsService.logScreen(screen: .eulaExplanation)
    }
    
    func approveTapped() {
        delegate?.approveTapped()
        trackGAEvent(eventLabel: .confirm)
    }
    
    private func trackGAEvent(eventLabel: GAEventLabel) {
        self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .mobilePaymentExplanation, eventLabel: eventLabel)
    }
    
}

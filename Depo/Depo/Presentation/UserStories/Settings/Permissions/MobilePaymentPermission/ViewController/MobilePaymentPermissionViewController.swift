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
    }
    
    private func setupNavigation() {
        hideTabBar()
        navigationBarWithGradientStyle()
        //backButtonForNavigationItem(title: TextConstants.backTitle)
        let backButton = UIBarButtonItem(title: TextConstants.backTitle, target: self, selector: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        guard let url = urlString else {
            return
        }
        delegate?.backTapped(url: url)
    }
    
}

// MARK: Mobile Payment Permission View Delegate
extension MobilePaymentPermissionViewController: MobilePaymentPermissionViewInput {
    
    func linkTapped() {
        guard let urlstring = urlString else {
            return
        }
        let viewController = WebViewController(urlString: urlstring)
        RouterVC().pushViewController(viewController: viewController)
    }
    
    func approveTapped() {
        delegate?.approveTapped()
    }
    
}

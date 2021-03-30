//
//  ProfileViewController.swift
//  Depo_LifeTech
//
//  Created by Vyacheslav Bakinskiy on 30.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class ProfileViewController: BaseViewController, NibInit {
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeLargeTitle(prefersLargeTitles: false, barStyle: .white)
        setView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(title: TextConstants.profilePageTitle, style: .white)
        setNavigationBarStyle(.white)
        
        if !Device.isIpad {
            setNavigationBarStyle(.byDefault)
        }
    }
    
    deinit {
//        webView.navigationDelegate = nil
//        webView.stopLoading()
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //MARK: - Private funcs
    
    private func setView() {
        view.backgroundColor = ColorConstants.tableBackground
    }
    
    
}

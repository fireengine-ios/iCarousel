//
//  ProfileViewController.swift
//  Depo_LifeTech
//
//  Created by Vyacheslav Bakinskiy on 30.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class ProfileViewController: BaseViewController, NibInit {
    
    //MARK: - Private properties
    
    private var profileTableViewAdapter: ProfileTableViewAdapter?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = view.bounds
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activityIndicator.color = UIColor.lightGray
        return activityIndicator
    }()
    
    //MARK: - @IBOutlets

    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeLargeTitle(prefersLargeTitles: false, barStyle: .white)
        setView()
        setActivityIndicator()
        profileTableViewAdapter = ProfileTableViewAdapter(with: tableView, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(title: TextConstants.profilePageTitle, style: .white)
        setNavigationBarStyle(.white)
        
        if !Device.isIpad {
            setNavigationBarStyle(.byDefault)
        }
    }
    
    //MARK: - Private funcs
    
    private func setView() {
        view.backgroundColor = ColorConstants.settingsTableBackground.color
    }
    
    private func setActivityIndicator() {
        view.addSubview(activityIndicator)
    }
    
    internal func startActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
    }
    
    internal func stopActivity() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
    }
}

//MARK: - ProfileDelegate

extension ProfileViewController: ProfileDelegate {
    func showActivityIndicator() {
        startActivity()
    }
    
    func hideActivityIndicator() {
        stopActivity()
    }
}

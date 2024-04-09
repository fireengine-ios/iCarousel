//
//  RaffleConditionViewController.swift
//  Depo
//
//  Created by Ozan Salman on 9.04.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class RaffleConditionViewController: BaseViewController {
    
    private lazy var topContentView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.raffleCondition.color
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var bottomContentView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.raffleCondition.color
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private var statusResponse: RaffleStatusResponse?
    
    init(statusResponse: RaffleStatusResponse?) {
        self.statusResponse = statusResponse
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("aaaaaaaaaaa \(view.frame.height)")
        print("aaaaaaaaaaa \(view.safeAreaInsets)")
        setTitle(withString: localized(.paycellCampaignDetailTitle))
        view.backgroundColor = AppColor.background.color
        setupPage()
    }
    
    
    
}

extension RaffleConditionViewController {
    private func setupPage() {
        let height = (view.frame.height / 2) - 70
        view.addSubview(topContentView)
        topContentView.translatesAutoresizingMaskIntoConstraints = false
        topContentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        topContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        topContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        topContentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        
        view.addSubview(bottomContentView)
        bottomContentView.translatesAutoresizingMaskIntoConstraints = false
        bottomContentView.topAnchor.constraint(equalTo: topContentView.bottomAnchor, constant: 20).isActive = true
        bottomContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        bottomContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        bottomContentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            print("aaaaaaaaaaa \(self.bottomContentView.frame.height)")
        })
        
        
        view.backgroundColor = .red
        
        
//        print("aaaaaaaaaaa \(navigationController?.navigationBar.frame.height)")
//        print("aaaaaaaaaaa \(topContentView.frame.height)")
//        print("aaaaaaaaaaa \(bottomContentView.frame.height)")
    }
}

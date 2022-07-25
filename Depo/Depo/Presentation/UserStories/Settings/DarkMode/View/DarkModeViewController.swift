//
//  DarkModeViewController.swift
//  Depo
//
//  Created by Burak Donat on 5.12.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class DarkModeViewController: BaseViewController {

    let storageVars: StorageVars = factory.resolve()

    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(withString: localized(.darkModePageTitle))
    }

    //MARK: -View
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var darkModeSwitchView: UIView = {
        let darkModeSwitchView = DarkModeOptionsView.initFromNib()
//        darkModeSwitchView.delegate = self
        return darkModeSwitchView
    }()

    //MARK: -Helpers
    private func setupLayout() {
        stackView.addArrangedSubview(darkModeSwitchView)
        view.addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: view.safeTopAnchor).activate()
        stackView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor).activate()
        stackView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor).activate()
        stackView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).activate()
    }
}


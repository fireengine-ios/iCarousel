//
//  ContactSyncOperationResultController.swift
//  Depo
//
//  Created by Konstantin Studilin on 03.06.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


final class ContactSyncOperationResultController: BaseViewController, NibInit {
    
    static func create(with view: UIView, navBarTitle: String) -> ContactSyncOperationResultController {
        let controller = ContactSyncOperationResultController.initFromNib()
        controller.resultView = view
        controller.navBarTitle = navBarTitle
        return controller
    }

    @IBOutlet private weak var contentView: UIView!
    
    private var resultView: UIView?
    private var navBarTitle = ""

    //MARK: - Override
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        showRelatedView()
    }
    
    //MARK: - Private
    
    private func setupNavBar() {
        navigationBarWithGradientStyle()
        setTitle(withString: navBarTitle)
    }
    
    private func showRelatedView() {
        resultView?.frame = contentView.bounds
        if let resultView = resultView {
            contentView.addSubview(resultView)
        }
    }
}

//
//  MobilePaymentPermissionViewController.swift
//  Depo
//
//  Created by YAGIZHAN AKDUMAN on 21.02.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class MobilePaymentPermissionViewController: ViewController, NibInit {
    
    weak var delegate: MobilePaymentPermissionProtocol?
    var urlString: String?
    
    override func loadView() {
        let mainView = MobilePaymentPermissionView.initFromNib()
        mainView.controller = self
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

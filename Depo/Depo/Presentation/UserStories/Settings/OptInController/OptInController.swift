//
//  OptInController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol OptInControllerDelegate {
    func set(optInNavigationTitle: String)
    func resendOptIn()
}

final class OptInController: UIViewController {

//    static func with(phone: String) -> OptInController {
//        let vc = OptInController(nibName: "OptInController", bundle: nil)
//
//        return vc
//    }
    
    private lazy var accountService = AccountService()
    
    var phone = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showIndicator()
        accountService.info(success: { [weak self] responce in
            guard let userInfoResponse = responce as? AccountInfoResponse,
                let number = userInfoResponse.phoneNumber
                else { return }
            self?.phone = number
            DispatchQueue.main.async {
                self?.hideIndicator()
            }
        },  fail: { [weak self] failResponse in
            DispatchQueue.main.async {
                self?.hideIndicator()
            }
                print(failResponse.description , self?.phone ?? "")
        })
    }
}

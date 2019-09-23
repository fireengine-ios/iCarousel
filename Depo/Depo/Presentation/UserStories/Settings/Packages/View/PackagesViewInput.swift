//
//  PackagesPackagesViewInput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PackagesViewInput: class, ActivityIndicator {
    func display(error: ErrorResponse)
    func display(errorMessage: String)
    func show(promocodeError: String)
    func successedPromocode()
    
    func showRestoreButton()
    func showInAppPolicy()
    func reloadData()

    func setupStackView(with storageCapacity: CGFloat)
}

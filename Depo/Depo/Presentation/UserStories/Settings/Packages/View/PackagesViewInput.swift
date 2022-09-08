//
//  PackagesPackagesViewInput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PackagesViewInput: AnyObject, ActivityIndicator {
    func setupStackView(with storageCapacity: CGFloat)
}

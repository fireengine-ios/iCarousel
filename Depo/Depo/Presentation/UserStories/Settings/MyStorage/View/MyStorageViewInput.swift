//
//  MyStorageViewInput.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol MyStorageViewInput: class, ActivityIndicator {
    func reloadCollectionView()
    
    func configureProgress(with full: Int64, used: Int64)
    
    func showRestoreButton()
}

//
//  PeriodicContactSyncViewInput.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol PeriodicContactSyncViewInput: AnyObject, ActivityIndicator {
    func startActivityIndicator()
    func stopActivityIndicator()
}

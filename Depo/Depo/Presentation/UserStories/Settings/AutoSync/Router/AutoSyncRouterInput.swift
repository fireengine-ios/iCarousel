//
//  AutoSyncAutoSyncRouterInput.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol AutoSyncRouterInput {
    func routNextVC()
    func showPopupForNewUser(with message: String, title: String, headerTitle: String)
}

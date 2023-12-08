//
//  NotificationViewInput.swift
//  Depo
//
//  Created by yilmaz edis on 9.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

protocol NotificationViewInput: AnyObject, ActivityIndicator {
    func reloadTableView()
    func setEmptyView(as hidden: Bool)
    func reloadTimer()
   
}

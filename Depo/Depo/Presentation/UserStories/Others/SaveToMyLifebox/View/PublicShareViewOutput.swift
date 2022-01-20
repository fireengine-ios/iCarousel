//
//  PublicShareViewOutput.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

protocol PublicShareViewOutput: AnyObject {
    func viewIsReady()
    func fetchMoreIfNeeded()
    func onSelect(item: WrapData)
    func onSaveButton(isLoggedIn: Bool)
    func popViewController()
    func onSelect(item: WrapData, items: [WrapData])
}

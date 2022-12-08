//
//  DeeplinkHandlerProtocol.swift
//  Depo
//
//  Created by yilmaz edis on 7.12.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

protocol DeeplinkHandlerProtocol {
    func canOpenURL(_ url: URL) -> Bool
    func openURL(_ url: URL)
}

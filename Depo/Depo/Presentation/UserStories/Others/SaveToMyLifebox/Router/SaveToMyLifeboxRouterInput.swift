//
//  SaveToMyLifeboxRouterInput.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol SaveToMyLifeboxRouterInput: AnyObject {
    func onSelect(item: WrapData)
    func popToRoot()
}

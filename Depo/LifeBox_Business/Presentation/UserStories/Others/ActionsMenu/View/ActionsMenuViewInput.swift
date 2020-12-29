//
//  ActionsMenuActionsMenuViewInput.swift
//  Depo
//
//  Created by Oleg on 17/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

typealias ActionClosure = () -> Void

struct ActionMenyItem {
    let name: String
    let action: ActionClosure
    
    init(name: String, action: @escaping ActionClosure) {
        self.name = name
        self.action = action
    }
}

protocol ActionsMenuViewInput: class {

    func showActions(actions: [ActionMenyItem])
}

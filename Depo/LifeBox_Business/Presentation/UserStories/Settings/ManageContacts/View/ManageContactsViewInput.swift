//
//  ManageContactsViewInput.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol ManageContactsViewInput: class {
    func showContacts(_ contactGroups: [ManageContacts.Group])
}

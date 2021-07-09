//
//  ManageContactsViewInput.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol ManageContactsViewInput: AnyObject {
    func showContacts(_ contactGroups: [ManageContacts.Group])
}

//
//  ManageContactsInteractorOutput.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol ManageContactsInteractorOutput: class {
    func didLoadContacts(_ contacts: [RemoteContact])
    func didDeleteContact()
    func asyncOperationStarted()
    func asyncOperationFinished()
}

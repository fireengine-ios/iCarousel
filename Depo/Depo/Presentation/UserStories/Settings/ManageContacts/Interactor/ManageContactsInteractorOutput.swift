//
//  ManageContactsInteractorOutput.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol ManageContactsInteractorOutput: AnyObject {
    func didLoadContacts(_ contacts: [RemoteContact])
    func deleteContact(_ completion: @escaping VoidHandler)
    func didDeleteContact()
    func asyncOperationStarted()
    func asyncOperationFinished()
}

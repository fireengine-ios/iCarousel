//
//  ManageContactsViewOutput.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol ManageContactsViewOutput {
    func viewIsReady()
    func onDeleteContact(_ contact: RemoteContact)
    func onSearch(_ query: String)
    func cancelSearch()
    func needLoadNextPage()
}

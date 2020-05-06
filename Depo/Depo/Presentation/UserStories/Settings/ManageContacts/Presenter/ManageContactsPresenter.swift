//
//  ManageContactsPresenter.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ManageContactsPresenter: BasePresenter, ManageContactsModuleInput, ManageContactsViewOutput, ManageContactsInteractorOutput {
    
    weak var view: ManageContactsViewInput!
    weak var moduleOutput: ManageContactsModuleOutput?
    var interactor: ManageContactsInteractorInput!
    var router: ManageContactsRouterInput!
    
    // MARK: View Output
    
    func viewIsReady() {
        interactor.loadContacts()
        asyncOperationStarted()
    }
    
    func onDeleteContact(_ contact: RemoteContact) {
        interactor.deleteContact(contact)
    }
    
    func needLoadNextPage() {
        interactor.continueLoading()
    }
    
    func onSearch(_ query: String) {
        interactor.searchContacts(query: query)
    }
    
    func cancelSearch() {
        interactor.cancelSearch()
    }
    
    // MARK: Interactor Output
    
    func deleteContact(_ completion: @escaping VoidHandler) {
        router.deleteContact(completion)
    }
    
    func didLoadContacts(_ contacts: [RemoteContact]) {
        let groupedContacts = groupContacts(contacts)
        DispatchQueue.main.async {
            self.view.showContacts(groupedContacts)
        }
    }
    
    func didDeleteContact() {
        moduleOutput?.didDeleteContact()
    }
    
    private func groupContacts(_ contacts: [RemoteContact]) -> [ManageContacts.Group] {
        var groupedContacts = [ManageContacts.Group]()
        
        for contact in contacts {
            let firstLetter = contact.name.uppercased().first
            if let lastGroup = groupedContacts.last, lastGroup.name == firstLetter {
                groupedContacts[groupedContacts.count - 1].contacts.append(contact)
            } else {
                guard let groupName = firstLetter else { continue }
                let group = ManageContacts.Group(name: groupName, contacts: [contact])
                groupedContacts.append(group)
            }
        }
        
        return groupedContacts
    }
    
    func asyncOperationStarted() {
        outputView()?.showSpinner()
    }
    
    func asyncOperationFinished() {
        outputView()?.hideSpinner()
    }
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

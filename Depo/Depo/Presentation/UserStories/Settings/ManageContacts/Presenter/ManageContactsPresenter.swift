//
//  ManageContactsPresenter.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ManageContactsPresenter: BasePresenter, ManageContactsModuleInput, ManageContactsViewOutput, ManageContactsInteractorOutput {
    weak var view: ManageContactsViewInput!
    var interactor: ManageContactsInteractorInput!
    var router: ManageContactsRouterInput!
    
    //MARK: View Output
    
    func viewIsReady() {
        interactor.loadContacts()
        asyncOperationStarted()
    }
    
    func onDeleteContact(_ contact: RemoteContact) {
        interactor.deleteContact(contact)
        asyncOperationStarted()
    }
    
    func didScrollToEnd() {
        interactor.continueLoading()
    }
    
    func onSearch(_ query: String) {
        interactor.searchContacts(query: query)
    }
    
    func cancelSearch() {
        interactor.cancelSearch()
    }
    
    //MARK: Interactor Output
    
    func didLoadContacts(_ contacts: [RemoteContact]) {
        let sortedContacts = sortContacts(contacts)
        DispatchQueue.main.async {
            self.view.showContacts(sortedContacts)
        }
    }
    
    private func sortContacts(_ contacts: [RemoteContact]) -> [ManageContacts.Group]  {
        var sortedContacts = [ManageContacts.Group]()
        
        for contact in contacts {
            let firstLetter = contact.name.uppercased().first
            if let index = sortedContacts.index(where: { $0.name == firstLetter } ) {
                sortedContacts[index].contacts.append(contact)
            } else {
                guard let groupName = firstLetter else { continue }
                let group = ManageContacts.Group(name: groupName, contacts: [contact])
                sortedContacts.append(group)
            }
        }
        
        return sortedContacts.sorted(by: { $0.name < $1.name } )
    }
    
    func asyncOperationStarted() {
        outputView()?.showSpiner()
    }
    
    func asyncOperationFinished() {
        outputView()?.hideSpiner()
    }
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

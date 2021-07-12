//
//  ManageContactsInteractor.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//


class ManageContactsInteractor: ManageContactsInteractorInput {

    enum Mode {
        case browse, search
    }
    
    weak var output: ManageContactsInteractorOutput!

    private let contactsSyncService = ContactsSyncService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    private var currentPage = 1
    private var numberOfPages = Int.max
    private var contacts = [RemoteContact]()
    private var lastQuery: String?
    
    private var mode: Mode = .browse
    private var isLoadingData = false
    
    // MARK: - Interactor Input
    
    func loadContacts() {
        if mode == .search {
            reset()
            output.asyncOperationStarted()
        }
        mode = .browse
        
        guard currentPage <= numberOfPages, !isLoadingData else {
            output.asyncOperationFinished()
            return
        }
        isLoadingData = true
        contactsSyncService.getContacts(with: currentPage, success: { [weak self] response in
            guard let `self` = self else { return }
            
            self.numberOfPages = response.numberOfPages
            self.currentPage += 1
            self.appendNewContacts(response.contacts)
            self.output.didLoadContacts(self.contacts)
            self.isLoadingData = false
            self.output.asyncOperationFinished()
        }, fail: { [weak self] error in
            guard let `self` = self else { return }
            self.isLoadingData = false
            self.output.asyncOperationFinished()
        })
    }
    
    func searchContacts(query: String) {
        if mode == .browse || lastQuery != query {
            reset()
            output.asyncOperationStarted()
        }
        mode = .search
        
        guard currentPage <= numberOfPages, !isLoadingData else {
            output.asyncOperationFinished()
            return
        }
        isLoadingData = true
        contactsSyncService.searchRemoteContacts(with: query, page: currentPage, success: { [weak self] response in
            guard let `self` = self else { return }
            
            self.numberOfPages = response.numberOfPages
            self.currentPage += 1
            self.lastQuery = query
            self.appendNewContacts(response.contacts)
            self.output.didLoadContacts(self.contacts)
            self.isLoadingData = false
            self.output.asyncOperationFinished()
        }, fail: { [weak self] error in
            guard let `self` = self else { return }
            self.isLoadingData = false
            self.output.asyncOperationFinished()
        })
    }
    
    func continueLoading() {
        switch mode {
        case .browse:
            loadContacts()
        case .search:
            guard let lastQuery = lastQuery else { return }
            searchContacts(query: lastQuery)
        }
    }
    
    func deleteContact(_ contact: RemoteContact) {
        let okHandler: VoidHandler = { [weak self] in
            guard let `self` = self else { return }
            
            self.output.asyncOperationStarted()
            self.contactsSyncService.deleteRemoteContacts([contact], success: { [weak self] _ in
                guard let `self` = self, let index = self.contacts.firstIndex(where: { $0.id == contact.id }) else {
                    return
                }
                self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .contact, eventLabel: .contactDelete)
                self.contacts.remove(at: index)
                self.output.didLoadContacts(self.contacts)
                self.output.asyncOperationFinished()
                self.output.didDeleteContact()
            }, fail: { [weak self] error in
                guard let `self` = self else { return }
                self.output.asyncOperationFinished()
            })
        }
        
        output.deleteContact(okHandler)
    }
    
    func cancelSearch() {
        if mode == .search {
            mode = .browse
            reset()
            loadContacts()
        }
    }
    
    private func appendNewContacts(_ newContacts: [RemoteContact]) {
        for contact in newContacts {
            if !contacts.contains(where: { $0.id == contact.id }) {
                contacts.append(contact)
            }
        }
    }
    
    private func reset() {
        lastQuery = nil
        currentPage = 1
        numberOfPages = Int.max
        contacts = [RemoteContact]()
        output.didLoadContacts(contacts)
    }
}

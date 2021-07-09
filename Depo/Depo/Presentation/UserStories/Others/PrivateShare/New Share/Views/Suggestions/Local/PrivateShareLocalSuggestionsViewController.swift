//
//  PrivateShareLocalSuggestionsViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 09.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


struct ContactInfo {
    let name: String
    let value: String
}


protocol PrivateShareSelectSuggestionsDelegate: class {
    func didSelect(contactInfo: ContactInfo)
    func contactListDidUpdate(isEmpty: Bool)
}


protocol PrivateShareSuggestionsViewController {
    var delegate: PrivateShareSelectSuggestionsDelegate? { get set }
    var contentView: UIView { get }
    func update(with searchString: String)
}


final class PrivateShareLocalSuggestionsViewController: UIViewController, NibInit, PrivateShareSuggestionsViewController {

    static func with(delegate: PrivateShareSelectSuggestionsDelegate?) -> PrivateShareSuggestionsViewController {
        let controller = PrivateShareLocalSuggestionsViewController.initFromNib()
        controller.delegate = delegate
        return controller
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.register(nibCell: PrivateShareLocalContactCell.self)
            
            newValue.estimatedRowHeight = 64
            newValue.rowHeight = UITableView.automaticDimension
            newValue.tableFooterView = UIView()
            
            newValue.allowsSelection = false
            newValue.separatorStyle = .singleLine

            newValue.delegate = self
            newValue.dataSource = self
        }
    }
    
    var contentView: UIView {
        return view
    }
    
    weak var delegate: PrivateShareSelectSuggestionsDelegate?

    private let localContactsService = ContactsSuggestionServiceImpl()
    private lazy var analytics = PrivateShareAnalytics()
    private var currentSuggestions = [SuggestedContact]()

    //MARK: - Public
    
    func update(with searchString: String) {
        if searchString.isEmpty {
            currentSuggestions = []
        } else {
            currentSuggestions = localContactsService.suggestContacts(for: searchString)
            delegate?.contactListDidUpdate(isEmpty: currentSuggestions.isEmpty)
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Private
    
    private func getContact(with searchString: String) -> [SuggestedContact] {
        return localContactsService.suggestContacts(for: searchString)
    }
}


extension PrivateShareLocalSuggestionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: PrivateShareLocalContactCell.self, for: indexPath)
        cell.delegate = self
        
        if let contact = currentSuggestions[safe: indexPath.row] {
            cell.update(with: contact)
        }
        
        return cell
    }
}


extension PrivateShareLocalSuggestionsViewController: PrivateShareLocalContactCellDelegate {
    func didSelect(contactInfo: ContactInfo) {
        analytics.addPhonebookSuggestion()
        delegate?.didSelect(contactInfo: contactInfo)
    }
}

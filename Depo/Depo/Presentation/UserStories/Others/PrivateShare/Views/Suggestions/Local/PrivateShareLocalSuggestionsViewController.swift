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


protocol PrivateShareLocalSuggestionsViewControllerDelegate: class {
    func didSelect(contactInfo: ContactInfo)
}


protocol PrivateShareSuggestionsViewController {
    var delegate: PrivateShareLocalSuggestionsViewControllerDelegate? { get set }
    
    func update(with searchString: String)
}


final class PrivateShareLocalSuggestionsViewController: UIViewController, NibInit, PrivateShareSuggestionsViewController {

    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.register(nibCell: PrivateShareLocalContactCell.self)
            
            newValue.estimatedRowHeight = 64
            newValue.rowHeight = UITableViewAutomaticDimension
            newValue.tableFooterView = UIView()
            
            newValue.allowsSelection = false
            newValue.separatorStyle = .singleLine

            newValue.delegate = self
            newValue.dataSource = self
        }
    }
    
    weak var delegate: PrivateShareLocalSuggestionsViewControllerDelegate?

    private let localContactsService = ContactsSuggestionServiceImpl()
    private var currentSuggestions = [SuggestedContact]()
    
    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
    }

    //MARK: - Public
    
    func update(with searchString: String) {
        currentSuggestions = localContactsService.suggestContacts(for: searchString)
        
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
        delegate?.didSelect(contactInfo: contactInfo)
    }
}

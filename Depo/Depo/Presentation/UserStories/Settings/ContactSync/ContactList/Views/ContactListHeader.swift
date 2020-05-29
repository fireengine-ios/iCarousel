//
//  ContactListHeader.swift
//  Depo
//
//  Created by Andrei Novikau on 5/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol ContactListHeaderDelegate: class {
    func startSearch(query: String?)
    func cancelSearch()
}

final class ContactListHeader: UIView, NibInit {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.contactListTitle
            newValue.font = .TurkcellSaturaDemFont(size: 24)
            newValue.textColor = ColorConstants.navy
        }
    }
    
    @IBOutlet private weak var backupInfoLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var searchBar: UISearchBar!  {
        willSet {
            newValue.backgroundColor = ColorConstants.toolbarTintColor
            newValue.tintColor = ColorConstants.darkBlueColor
            newValue.delegate = self
            newValue.searchBarStyle = .minimal
            newValue.setImage(UIImage(named: TextConstants.searchIcon), for: .search, state: .normal)
            
            if let textField = newValue.textField {
                textField.backgroundColor = ColorConstants.toolbarTintColor
                textField.placeholder = TextConstants.search
                textField.placeholderLabel?.textColor = ColorConstants.lightText
                textField.font = .TurkcellSaturaDemFont(size: 16)
                textField.textColor = ColorConstants.darkBlueColor
                textField.keyboardAppearance = .dark
            }
            
            if let cancelButton = newValue.cancelButton {
                cancelButton.titleLabel?.font = .TurkcellSaturaRegFont(size: 17)
                cancelButton.backgroundColor = .clear
            }
        }
    }
    
    private weak var delegate: ContactListHeaderDelegate?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY"
        return formatter
    }()
    
    
    static func with(delegate: ContactListHeaderDelegate?) -> ContactListHeader {
        let header = ContactListHeader.initFromNib()
        header.delegate = delegate
        return header
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.toolbarTintColor
    }
    
    func setup(with backUpInfo: ContactSync.SyncResponse?) {
        guard let backUpInfo = backUpInfo else {
            return
        }
        
        let date = backUpInfo.date ?? Date()
        let dateString = dateFormatter.string(from: date)
        
        let string = String(format: TextConstants.contactListInfo, backUpInfo.totalNumberOfContacts, dateString)
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [.font: UIFont.TurkcellSaturaMedFont(size: 16),
                                                                      .foregroundColor: ColorConstants.duplicatesGray])
        
        let countRange = (string as NSString).range(of: "\(backUpInfo.totalNumberOfContacts)")
        attributedString.addAttribute(.font, value: UIFont.TurkcellSaturaBolFont(size: 16), range: countRange)
        
        let dateRange = (string as NSString).range(of: dateString)
        attributedString.addAttribute(.font, value: UIFont.TurkcellSaturaBolFont(size: 16), range: dateRange)
        
        backupInfoLabel.attributedText = attributedString
    }
}

//MARK: - UISearchBarDelegate

extension ContactListHeader: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.startSearch(query: searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.cancelSearch()
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

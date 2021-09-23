//
//  ContactListHeader.swift
//  Depo
//
//  Created by Andrei Novikau on 5/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol ContactListHeaderDelegate: AnyObject {
    func search(query: String?)
    func cancelSearch()
}

final class ContactListHeader: UIView, NibInit {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.contactListTitle
            newValue.font = .TurkcellSaturaDemFont(size: 24)
            newValue.textColor = AppColor.navyAndWhite.color
        }
    }
    
    @IBOutlet private weak var backupInfoLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!  {
        willSet {
            newValue.backgroundColor = ColorConstants.toolbarTintColor
            newValue.tintColor = AppColor.navyAndWhite.color
            newValue.delegate = self
            newValue.searchBarStyle = .minimal
            newValue.setImage(UIImage(named: TextConstants.searchIcon), for: .search, state: .normal)
            
            if let textField = newValue.textField {
                textField.backgroundColor = ColorConstants.toolbarTintColor
                textField.placeholder = TextConstants.search
                textField.placeholderLabel?.textColor = ColorConstants.lightText
                textField.font = .TurkcellSaturaDemFont(size: 16)
                textField.textColor = AppColor.navyAndWhite.color
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
    
    func setup(with backUpInfo: ContactBackupItem?) {
        guard let backUpInfo = backUpInfo else {
            return
        }
        
        let date = backUpInfo.created ?? Date()
        let dateString = dateFormatter.string(from: date)
        
        let string = String(format: TextConstants.contactListInfo, backUpInfo.total, dateString)
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [.font: UIFont.TurkcellSaturaMedFont(size: 16),
                                                                      .foregroundColor: ColorConstants.duplicatesGray])
        
        let countRange = (string as NSString).range(of: "\(backUpInfo.total)")
        attributedString.addAttribute(.font, value: UIFont.TurkcellSaturaBolFont(size: 16), range: countRange)
        
        let dateRange = (string as NSString).range(of: dateString)
        attributedString.addAttribute(.font, value: UIFont.TurkcellSaturaBolFont(size: 16), range: dateRange)
        
        backupInfoLabel.attributedText = attributedString
    }
}

//MARK: - UISearchBarDelegate

extension ContactListHeader: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            delegate?.cancelSearch()
        } else {
            delegate?.search(query: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.enableCancelButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.cancelSearch()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}

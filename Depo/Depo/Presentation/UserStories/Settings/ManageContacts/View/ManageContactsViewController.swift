//
//  ManageContactsViewController.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ManageContactsViewController: BaseViewController, ManageContactsViewInput {

    @IBOutlet weak var tableView: UITableView!
    
    var output: ManageContactsViewOutput!
    
    private var searchBar = UISearchBar()

    private var contactGroups = [ManageContacts.Group]()
    
    private let cellIdentifier = "ManageContactTableViewCell"
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButtonForNavigationItem(title: TextConstants.backTitle)
        setTitle(withString: TextConstants.manageContacts)

        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        output.viewIsReady()
        
        configureSearchBar()
    }
    
    private func configureSearchBar() {
        
        var searchBarHeight: CGFloat = 44
        
        if #available(iOS 11.0, *) {
            searchBarHeight = 56
        }
        
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: searchBarHeight))
        self.searchBar = searchBar
        
        searchBar.backgroundColor = ColorConstants.whiteColor
        searchBar.tintColor = ColorConstants.darcBlueColor
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.setImage(UIImage(named: TextConstants.searchIcon), for: .search, state: .normal)
        for subView in (searchBar.subviews.first?.subviews)! {
            if subView.isKind(of: UITextField.self) {
                let textFileld = (subView as! UITextField)
                textFileld.backgroundColor = ColorConstants.whiteColor
                textFileld.placeholder = TextConstants.search
                textFileld.font = UIFont.TurkcellSaturaDemFont(size: 19)
                textFileld.textColor = ColorConstants.darcBlueColor
                textFileld.keyboardAppearance = .dark
            }
            if subView.isKind(of: UIButton.self) {
                (subView as! UIButton).titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 17)
            }
        }
        
        self.tableView.tableHeaderView = searchBar
    }
    
    // MARK: Actions
    
    // MARK: ManageContactsViewInput
    
    func showContacts(_ contactGroups: [ManageContacts.Group]) {
        self.contactGroups = contactGroups
        tableView.reloadData()
    }
}

extension ManageContactsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactGroups[section].contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ManageContactTableViewCell else {
            return UITableViewCell()
        }
        
        let contact = contactGroups[indexPath.section].contacts[indexPath.row]
        cell.configure(with: contact, delegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(contactGroups[section].name)
    }
}

extension ManageContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        
        headerView.textLabel?.font = UIFont.TurkcellSaturaRegFont(size: 16)
        headerView.textLabel?.textColor = ColorConstants.textGrayColor
    }
}

extension ManageContactsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, query.count > 0 {
            output.onSearch(query)
        } else {
            cancelSearch()
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelSearch()
    }
    
    private func cancelSearch() {
        output.cancelSearch()
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}

extension ManageContactsViewController: ManageContactTableViewCellDelegate {
    func cell(_ cell: ManageContactTableViewCell, deleteContact: RemoteContact) {
        output.onDeleteContact(deleteContact)
    }
}

extension ManageContactsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if deltaOffset(for: scrollView) <= 0 {
            output.didScrollToEnd()
        }
    }
    
    private func deltaOffset(for scrollView: UIScrollView) -> CGFloat {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let infinity = tableView.tableFooterView?.bounds.height ?? 0
        return maximumOffset - currentOffset - infinity
    }
}

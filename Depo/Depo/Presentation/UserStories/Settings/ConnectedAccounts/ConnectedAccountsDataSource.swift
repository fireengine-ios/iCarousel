//
//  ConnectedAccountsDataSource.swift
//  Depo
//
//  Created by Konstantin Studilin on 07/02/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


final class Section {
    enum SocialAccount: Int {
        case spotify
        case instagram
        case facebook
        case dropbox
    }
    
    enum ExpandState: Int {
        case shrinked
        case expanded
    }
    
    private(set) var account: SocialAccount
    private(set) var state: ExpandState
    private(set) var mediator = SocialAccountSectionMediator()
    
    var numberOfRows: Int {
        return (state == .shrinked) ? 1 : 2
    }
    
    
    init(account: SocialAccount, state: ExpandState) {
        self.account = account
        self.state = state
    }
    
    func set(expanded: Bool) -> Bool {
        let newState: ExpandState = expanded ? .expanded : .shrinked
        let isUpdated = (state != newState)
        state = newState
        return isUpdated
    }
}


final class ConnectedAccountsDataSource: NSObject {
    
    weak var view: SocialConnectionCellDelegate?
    
    private let tableSections = [Section(account: .spotify, state: .shrinked),
                                 Section(account: .instagram, state: .shrinked),
                                 Section(account: .facebook, state: .shrinked),
                                 Section(account: .dropbox, state: .shrinked)]
}

// MARK: - UITableViewDataSource
extension ConnectedAccountsDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSections[safe: section]?.numberOfRows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = cell(for: tableView, at: indexPath)
        setup(cell: reusableCell, at: indexPath)
        
        return reusableCell
    }
    
    private func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard
            let section = tableSections[safe: indexPath.section],
            let stateForRow = Section.ExpandState(rawValue: indexPath.row)
        else {
            assertionFailure("wrong indexPath")
            return UITableViewCell()
        }
        
        let cellId: String
        switch (section.account, stateForRow) {
        case (.instagram, .shrinked):
            cellId = CellsIdConstants.instagramAccountConnectionCell
        case (.facebook, .shrinked):
            cellId = CellsIdConstants.facebookAccountConnectionCell
        case (.dropbox, .shrinked):
            cellId = CellsIdConstants.dropboxAccountConnectionCell
        case (.spotify, .shrinked):
            cellId = CellsIdConstants.spotifyAccountConnectionCell
            
        case (_, .expanded):
            cellId = CellsIdConstants.socialAccountRemoveConnectionCell
     
        }
        
        return tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
    }
    
    private func setup(cell: UITableViewCell, at indexPath: IndexPath) {
        let section = tableSections[safe: indexPath.section]
        
        if let cell = cell as? SocialConnectionCell {
            section?.mediator.set(socialConnectionCell: cell)
            cell.setup(with: section)
            cell.delegate = view
        } else if let cell = cell as? SocialRemoveConnectionCell {
            
            if section?.account == Section.SocialAccount.spotify {
                cell.spotifySetup(with: section)
                
            } else {
                cell.setup(with: section)
            }
            section?.mediator.set(removeConnectionCell: cell)
        }
    }
}

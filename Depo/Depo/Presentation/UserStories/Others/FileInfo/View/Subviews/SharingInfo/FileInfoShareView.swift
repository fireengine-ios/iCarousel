//
//  FileInfoShareView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/13/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol FileInfoShareViewProtocol: UIView {
    func setup(with info: SharedFileInfo)
    
    var info: SharedFileInfo? { get }
}

protocol FileInfoShareViewDelegate: AnyObject {
    func didSelect(contact: SharedContact)
    func didTappedPlusButton()
    func didTappedArrowButton()
}

final class FileInfoShareView: UIView, NibInit, FileInfoShareViewProtocol {
    
    private typealias MembersInfo = (displayContacts: [SharedContact], totalCount: Int, additionalCount: Int)
    
    static func with(delegate: FileInfoShareViewDelegate?) -> FileInfoShareViewProtocol {
        let view = FileInfoShareView.initFromNib()
        view.delegate = delegate
        return view
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.privateShareInfoMenuSectionTitle
            newValue.textColor = AppColor.filesLabel.color
            newValue.font = .appFont(.regular, size: 14)
        }
    }
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = AppColor.filesLabel.color
            newValue.font = .appFont(.light, size: 14)
        }
    }
    
    @IBOutlet private weak var contactsCollectionView: UICollectionView! {
        didSet {
            setupCollectionView()
        }
    }
    
    @IBOutlet private weak var arrowButton: UIButton!
    
    private weak var delegate: FileInfoShareViewDelegate?
    
    private(set) var info: SharedFileInfo?
    private var membersInfo: MembersInfo = ([], 0, 0)
    
    private let maxDisplayMembers = 3
    
    //MARK: - FileInfoShareViewProtocol
    
    func setup(with info: SharedFileInfo) {
        self.info = info
        
        membersInfo = getMembersInfo()
        
        subtitleLabel.text = String(format: TextConstants.privateShareInfoMenuNumberOfPeople, membersInfo.totalCount)
        contactsCollectionView.reloadData()
    }
    
    //MARK: - Private
    
    private func setupCollectionView() {
        contactsCollectionView.register(nibCell: FileInfoShareContactCell.self)
        contactsCollectionView.dataSource = self
        
        if let layout = contactsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 50, height: 67)
            layout.minimumLineSpacing = 2
        }
    }
    
    private func getMembersInfo() -> MembersInfo {
        guard let members = info?.members, !members.isEmpty else {
            return ([], 0, 0)
        }
        
        var result = [SharedContact]()
        
        if members.count <= maxDisplayMembers {
            result = members
        } else {
            let sortedRoles: [PrivateShareUserRole] = [.owner, .editor, .viewer]
            sortedRoles.forEach { role in
                if let contact = members.first(where: { $0.role == role }) {
                    result.append(contact)
                }
            }
            while result.count < maxDisplayMembers {
                if let contact = members.first(where: { !result.contains($0) }) {
                    result.append(contact)
                }
            }
            result.sort(by: { $0.role.order < $1.role.order })
        }

        return (result, members.count, members.count - result.count)
    }
    
    @IBAction private func onArrowTapped() {
        delegate?.didTappedArrowButton()
    }
}

//MARK: - UICollectionViewDataSource

extension FileInfoShareView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var itemsCount = membersInfo.displayContacts.count
        if membersInfo.additionalCount > 0 {
            //increment for +N circle
            itemsCount += 1
        }
        if itemsCount > 0 {
            //increment for add button
            itemsCount += 1
        }
        return itemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: FileInfoShareContactCell.self, for: indexPath)
        
        let type: FileInfoShareContactCellType
        let contact = membersInfo.displayContacts[safe: indexPath.item]
        
        if indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
            type = .plusButton
        } else if indexPath.item == membersInfo.displayContacts.count, membersInfo.additionalCount > 0 {
            type = .additionalCount
        } else {
            type = .contact
        }
        
        cell.setup(type: type, contact: contact, count: membersInfo.additionalCount, index: indexPath.item)
        cell.delegate = self
        return cell
    }
}

//MARK: - FileInfoShareContactCellDelegate

extension FileInfoShareView: FileInfoShareContactCellDelegate {
    
    func didSelect(contact: SharedContact) {
        delegate?.didSelect(contact: contact)
    }
    
    func didTappedPlusButton() {
        delegate?.didTappedPlusButton()
    }
    
    func didTappedOnShowAllContacts() {
        delegate?.didTappedArrowButton()
    }
}

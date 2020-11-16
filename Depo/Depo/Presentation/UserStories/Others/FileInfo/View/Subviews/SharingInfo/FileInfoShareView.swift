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
}

protocol FileInfoShareViewDelegate: class {
    
}

final class FileInfoShareView: UIView, NibInit, FileInfoShareViewProtocol {
    
    static func with(delegate: FileInfoShareViewDelegate?) -> FileInfoShareViewProtocol {
        let view = FileInfoShareView.initFromNib()
        return view
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = "Sharing Info"
            newValue.textColor = ColorConstants.marineTwo
            newValue.font = .TurkcellSaturaBolFont(size: 14)
        }
    }
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = .lrBrownishGrey
            newValue.font = .TurkcellSaturaDemFont(size: 16)
        }
    }
    
    @IBOutlet private weak var contactsCollectionView: UICollectionView! {
        didSet {
            setupCollectionView()
        }
    }
    
    @IBOutlet private weak var arrowButton: UIButton!
    
    private var info: SharedFileInfo?
    
    //MARK: - FileInfoShareViewProtocol
    
    func setup(with info: SharedFileInfo) {
        self.info = info
        
        let count = info.members?.count ?? 0
        subtitleLabel.text = "Shared with \(count) people"
        contactsCollectionView.reloadData()
    }
    
    //MARK: - Private
    
    private func setupCollectionView() {
        contactsCollectionView.register(nibCell: FileInfoShareContactCell.self)
        contactsCollectionView.dataSource = self
        
        if let layout = contactsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 45, height: 67)
            layout.minimumLineSpacing = 10
        }
    }
}

//MARK: - UICollectionViewDataSource

extension FileInfoShareView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if var contactsCount = info?.members?.count {
            if contactsCount > 3 {
                //increment for +N circle
                contactsCount += 1
            }
            //increment for add button
            return contactsCount + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: FileInfoShareContactCell.self, for: indexPath)
        let type: FileInfoShareContactCellType
        let contactsCount = info?.members?.count ?? 0
        let contact = info?.members?[safe: indexPath.item]
        
        if indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
            type = .plusButton
        } else if contactsCount > 3, indexPath.item >= 3 {
            type = .additionalCount
        } else {
            type = .contact
        }
        
        cell.setup(type: type, contact: contact, count: contactsCount - 3, index: indexPath.item)
        return cell
    }
}

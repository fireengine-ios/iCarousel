//
//  SharingInfoTableViewCell.swift
//  Depo
//
//  Created by Anton Ignatovich on 24.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol SharingInfoTableViewCellDelegate: class {
    func didSelect(contact: SharedContact, cell: SharingInfoTableViewCell)
    func didTappedPlusButton(cell: SharingInfoTableViewCell)
    func didTappedArrowButton(sharedEntityItem: SharedFileInfo, cell: SharingInfoTableViewCell)
}

final class SharingInfoTableViewCell: UITableViewCell {

    weak var delegate: SharingInfoTableViewCellDelegate?

    private lazy var sharingInfoView: FileInfoShareViewProtocol = {
        let vview = FileInfoShareView.with(delegate: self)
        vview.translatesAutoresizingMaskIntoConstraints = false
        return vview
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        baseSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        baseSetup()
    }

    private func baseSetup() {
        contentView.backgroundColor = ColorConstants.tableBackground
        contentView.addSubview(sharingInfoView)
        sharingInfoView.pinToSuperviewEdges()
    }
    
    func setup(with entity: SharedFileInfo) {
        sharingInfoView.setup(with: entity)
    }
}

// MARK: - FileInfoShareViewDelegate
extension SharingInfoTableViewCell: FileInfoShareViewDelegate {
    func didTappedArrowButton(sharedFileInfo: SharedFileInfo, view: FileInfoShareView) {
        delegate?.didTappedArrowButton(sharedEntityItem: sharedFileInfo, cell: self)
    }

    func didSelect(contact: SharedContact, view: FileInfoShareView) {
        delegate?.didSelect(contact: contact, cell: self)
    }

    func didTappedPlusButton(view: FileInfoShareView) {
        delegate?.didTappedPlusButton(cell: self)
    }
}

//
//  ContactListMainView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol ContactListMainViewDelegate: AnyObject {
    func onRestoreTapped()
    func onReloadData()
    func search(query: String?)
    func cancelSearch()
}

final class ContactListMainView: UIView, NibInit {

    static func with(backUpInfo: ContactBackupItem?, delegate: ContactListMainViewDelegate?) -> ContactListMainView {
        let view = ContactListMainView.initFromNib()
        view.backUpInfo = backUpInfo
        view.delegate = delegate
        return view
    }
    
    @IBOutlet private(set) weak var tableView: UITableView!
    
    @IBOutlet private weak var shadowView: UIView! {
        willSet {
            let gradientView = TransparentGradientView(style: .vertical, mainColor: AppColor.primaryBackground.color ?? ColorConstants.lighterGray)
            gradientView.frame = newValue.bounds
            newValue.addSubview(gradientView)
            newValue.sendSubviewToBack(gradientView)
            gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var restoreButton: RoundedButton! {
        willSet {
            newValue.setTitle(TextConstants.contactListRestore, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = ColorConstants.navy
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 16)
        }
    }
    
    private weak var delegate: ContactListMainViewDelegate?
    private var backUpInfo: ContactBackupItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRefreshControl()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if tableView.tableHeaderView == nil {
            setupHeader()
        }
    }
    
    private func setupHeader() {
        let header = ContactListHeader.with(delegate: self)
        header.setup(with: backUpInfo)
        
        let size = header.sizeToFit(width: tableView.bounds.width)
        header.frame.size = size
        
        tableView.tableHeaderView = header
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ColorConstants.whiteColor
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    //MARK: - Actions
    
    @IBAction func restore(_ sender: UIButton) {
        delegate?.onRestoreTapped()
    }
    
    @objc func reloadData() {
        delegate?.onReloadData()
    }
}

//MARK: - ContactListHeaderDelegate

extension ContactListMainView: ContactListHeaderDelegate {
    func search(query: String?) {
        delegate?.search(query: query)
    }
    
    func cancelSearch() {
        delegate?.cancelSearch()
    }
}

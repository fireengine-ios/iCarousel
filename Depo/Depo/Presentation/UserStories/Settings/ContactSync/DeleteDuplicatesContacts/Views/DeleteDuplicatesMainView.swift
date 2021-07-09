//
//  DeleteDuplicatesMainView.swift
//  Depo
//
//  Created by Andrei Novikau on 7/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol DeleteDuplicatesMainViewDelegate: class {
    func onDeleteAllTapped()
}

final class DeleteDuplicatesMainView: UIView, NibInit {

    static func with(contacts: [ContactSync.AnalyzedContact], delegate: DeleteDuplicatesMainViewDelegate?) -> DeleteDuplicatesMainView {
        let view = DeleteDuplicatesMainView.initFromNib()
        view.contacts = contacts
        view.delegate = delegate
        return view
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var shadowView: UIView! {
        willSet {
            let gradientView = TransparentGradientView(style: .vertical, mainColor: ColorConstants.lighterGray)
            gradientView.frame = newValue.bounds
            newValue.addSubview(gradientView)
            newValue.sendSubviewToBack(gradientView)
            gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var deleteAllButton: RoundedButton! {
        willSet {
            newValue.setTitle(TextConstants.deleteDuplicatesDeleteAll, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = ColorConstants.navy
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 16)
        }
    }
    
    private var contacts = [ContactSync.AnalyzedContact]()
    private weak var delegate: DeleteDuplicatesMainViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTableView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let tableView = tableView, tableView.tableHeaderView == nil {
            setupHeader()
        }
    }

    private func setupTableView() {
        tableView.register(nibCell: DeleteDuplicatesCell.self)
        tableView.dataSource = self

        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset.bottom = bottomView.bounds.height
    }
    
    private func setupHeader() {
        let numberOfAllDuplicatedContacts = contacts.reduce(0) { $0 + $1.numberOfErrors }

        let header = DeleteDuplicatesHeader.initFromNib()
        header.setup(with: numberOfAllDuplicatedContacts)
        tableView.tableHeaderView = header
    }

    
    @IBAction private func onDeleteAllTapped(_ sender: Any) {
        delegate?.onDeleteAllTapped()
    }
}

// MARK: - UITableViewDataSource

extension DeleteDuplicatesMainView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: DeleteDuplicatesCell.self, for: indexPath)
        cell.configure(with: contacts[indexPath.row])
        
        return cell
    }
}

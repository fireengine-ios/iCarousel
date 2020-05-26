//
//  DeleteDuplicatesViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 5/25/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol DeleteDuplicatesDelegate: class {
    func startBackUp()
    func deleteDuplicatesClosed()
    func deleteDuplicatesStarted()
    func deleteDuplicatesSuccess()
    func deleteDuplicatesFailed()
}

final class DeleteDuplicatesViewController: BaseViewController, NibInit {
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var deleteAllButton: BlueButtonWithMediumWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.deleteDuplicatesDeleteAll, for: .normal)
        }
    }
    
    private var contacts = [ContactSync.AnalyzedContact]()
    private weak var delegate: DeleteDuplicatesDelegate?
    private var resultView: ContactsOperationView?
    
    // MARK: -
    
    static func with(contacts: [ContactSync.AnalyzedContact], delegate: DeleteDuplicatesDelegate?) -> DeleteDuplicatesViewController {
        let controller = DeleteDuplicatesViewController.initFromNib()
        controller.contacts = contacts
        controller.delegate = delegate
        return controller
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButtonForNavigationItem(title: TextConstants.backTitle)
        setTitle(withString: TextConstants.deleteDuplicatesTitle)
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.deleteDuplicatesClosed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView.tableHeaderView == nil {
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
    
    // MARK: - Actions
    
    @IBAction private func onDeleteAllTapped(_ sender: Any) {
        let vc = PopUpController.with(title: TextConstants.deleteDuplicatesConfirmTitle,
                                      message: TextConstants.deleteDuplicatesConfirmMessage,
                                      image: .delete,
                                      firstButtonTitle: TextConstants.cancel,
                                      secondButtonTitle: TextConstants.ok,
                                      secondAction: { [weak self] vc in
                                        vc.close()
                                        self?.deleteDuplicates()
                                    })
        present(vc, animated: false)
    }
    
    private func deleteDuplicates() {
//        showSpinner()
        
        delegate?.deleteDuplicatesStarted()
        //TODO: Start Delete in service
        deleteDuplicatesSuccess()
    }
    
    private func deleteDuplicatesSuccess() {
        delegate?.deleteDuplicatesSuccess()
        
        showResultView(result: .success)
        
        let backUpCard = BackUpContactsCard.initFromNib()
        resultView?.add(card: backUpCard)
        
        backUpCard.backUpHandler = { [weak self] in
            self?.delegate?.startBackUp()
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func deleteDuplicatesFailed() {
        delegate?.deleteDuplicatesFailed()
        showResultView(result: .failed)
    }
    
    private func showResultView(result: ContactsOperationResult) {
        deleteResultView()
        
        resultView = ContactsOperationView.with(type: .deleteDuplicates, result: result)
        resultView?.frame = view.bounds
        resultView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(resultView!)
    }
    
    private func deleteResultView() {
        resultView?.removeFromSuperview()
        resultView = nil
    }
}

// MARK: - UITableViewDataSource

extension DeleteDuplicatesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: DeleteDuplicatesCell.self, for: indexPath)
        cell.configure(with: contacts[indexPath.row])
        
        return cell
    }
}

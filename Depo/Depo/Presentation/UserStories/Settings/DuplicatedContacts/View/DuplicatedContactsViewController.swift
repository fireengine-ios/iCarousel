//
//  DuplicatedContactsViewController.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class DuplicatedContactsViewController: BaseViewController, DuplicatedContactsViewInput {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var deleteAllButton: BlueButtonWithMediumWhiteText!
    @IBOutlet private weak var keepButton: BlueButtonWithMediumWhiteText!
    
    private let cellIdentifier = "DuplicatedContactTableViewCell"
    
    var output: DuplicatedContactsViewOutput!
    var analyzeResponse = [ContactSync.AnalyzedContact]()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numberOfAllDuplicatedContacts = analyzeResponse.reduce(0) { $0 + $1.numberOfErrors }
        titleLabel.text = String(format: TextConstants.settingsBackUpTotalNumberOfDuplicatedContacts, numberOfAllDuplicatedContacts)
        
        backButtonForNavigationItem(title: TextConstants.backTitle)
        setTitle(withString: TextConstants.duplicatedContacts)
        
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        deleteAllButton.setTitle(TextConstants.settingsBackUpDeleteAllButton, for: .normal)
        keepButton.setTitle(TextConstants.settingsBackUpKeepButton, for: .normal)
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        output.onWillDisappear()
    }
    
    // MARK: - IBActions
    
    @IBAction func onDeleteAllTapped(_ sender: Any) {
        output.onDeleteAllTapped()
    }
    
    @IBAction func onKeepTapped(_ sender: Any) {
        output.onKeepTapped()
    }
}

// MARK: - UITableViewDataSource

extension DuplicatedContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return analyzeResponse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DuplicatedContactTableViewCell
        cell.configure(with: analyzeResponse[indexPath.row])
        
        return cell
    }
}

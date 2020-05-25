//
//  DuplicatedContectsViewControllerV2.swift
//  Depo
//
//  Created by Raman Harhun on 5/21/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

class DuplicatedContactsViewControllerV2: BaseViewController, DuplicatedContactsViewInput {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteAllButton: UIButton!
        
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
}

// MARK: - UITableViewDataSource

extension DuplicatedContactsViewControllerV2: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return analyzeResponse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DuplicatedContactTableViewCell
        cell.configure(with: analyzeResponse[indexPath.row])
        
        return cell
    }
}


//
//  RegistrationRegistrationViewController.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, RegistrationViewInput {
    
    @IBOutlet weak var userRegistrationTable: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    var output: RegistrationViewOutput!
    let dataSource = RegistrationDataSource()

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        output.viewIsReady()
        self.userRegistrationTable.dataSource = self.dataSource
        self.userRegistrationTable.delegate = self.dataSource
        self.output.prepareCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userRegistrationTable.register(UINib(nibName: "BaseUserInputCell", bundle: nil), forCellReuseIdentifier: "BaseUserInputCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    // MARK: RegistrationViewInput
    func setupInitialState() {
    
    }

    func setupRow(forRowIdex rowIndex: Int, withTitle title: String) {
        //setup row
    }
    
    func setupInitialState(withModels: [BaseCellModel]) {
        self.dataSource.setupCells(withModels: withModels)
        self.userRegistrationTable.reloadData()
    }
    
    func validationResults(forRow: Int, withValue: String, result: NSError?) {
        
    }
    
    @IBAction func nextActionHandler(_ sender: Any) {
        guard let navController = self.navigationController else {
            return
        }
        self.output.handleTermsAndServices(withNavController: navController)//handleNextAction()
    }
}

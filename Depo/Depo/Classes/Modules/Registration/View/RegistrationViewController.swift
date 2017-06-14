//
//  RegistrationRegistrationViewController.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, RegistrationViewInput, DataSourceOutput {
    
    @IBOutlet weak var userRegistrationTable: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    var output: RegistrationViewOutput!
    let dataSource = RegistrationDataSource()

    @IBOutlet weak var pickerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var picker: CountryPickerView!
    
    @IBOutlet weak var pickerContainer: UIView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString(TextConstants.registerTitle, comment: "")
//        output.viewIsReady()
        Bundle.main.loadNibNamed("CountryPicker", owner: self, options: nil)
        self.picker.pickerView.dataSource = self.dataSource
        self.picker.pickerView.delegate = self.dataSource
        
        picker.frame = CGRect(x: 0, y: 0, width: self.pickerContainer.bounds.width, height: self.pickerContainer.bounds.height)
        self.pickerContainer.addSubview(picker)
        self.dataSource.output = self
        self.userRegistrationTable.dataSource = self.dataSource
        self.userRegistrationTable.delegate = self.dataSource
        self.output.prepareCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userRegistrationTable.register(UINib(nibName: "BaseUserInputCell", bundle: nil), forCellReuseIdentifier: "BaseUserInputCell")
        self.userRegistrationTable.register(UINib(nibName: "GSMUInputCell", bundle: nil), forCellReuseIdentifier: "GSMUserInputCellID")
        
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
    
    func setupPicker(withModels: [GSMCodeModel]) {
        
        self.dataSource.setupPickerCells(withModels: withModels)
        self.picker.pickerView.reloadAllComponents()
    }
    
    @IBAction func nextActionHandler(_ sender: Any) {
        guard let navController = self.navigationController else {
            return
        }
        self.output.nextButtonPressed(withNavController: navController, email: self.getTextFieldValue(forRow: 0), phone: self.getTextFieldValue(forRow: 1), password: self.getTextFieldValue(forRow: 2), repassword: self.getTextFieldValue(forRow: 3))
        //handleTermsAndServices(withNavController: navController)//handleNextAction()
    }
    
    private func getTextFieldValue(forRow: Int) -> String {

        guard let baseCell = self.userRegistrationTable.cellForRow(at: IndexPath(item: forRow, section: 0)) as? BaseUserInputCellView else {
            return ""
        }
        let textFieldValue = baseCell.textInputField.text
        if baseCell is GSMUserInputCell {
            let gsmCodeWithPhone = self.dataSource.getGSMCode(forRow: forRow) + textFieldValue!
            return gsmCodeWithPhone
        }

        return textFieldValue!
    }
    
    func prepareNavController() {
        guard let navController = self.navigationController else {
            return
        }
        self.output.readyForPassing(withNavController: navController)
    }
    
    //MARK: - DataSource output
    @IBAction func pickerChoosePressed(_ sender: Any) {
        self.pickerBottomConstraint.constant = -271
        let currentRow = self.picker.pickerView.selectedRow(inComponent: 0)
        self.dataSource.changeGSMCodeLabel(withRow: currentRow)
        self.userRegistrationTable.reloadRows(at: [IndexPath(item: 1, section: 0)], with: UITableViewRowAnimation.automatic)
//        self.dataSource.current
        
    }
    func pickerGotTapped() {
        self.pickerBottomConstraint.constant = 0
    }
}

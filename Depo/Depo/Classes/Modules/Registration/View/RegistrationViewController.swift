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
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    @IBOutlet weak var pickerContainer: UIView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        Bundle.main.loadNibNamed("CountryPicker", owner: self, options: nil)
        self.pickerView.dataSource = self.dataSource
        self.pickerView.delegate = self.dataSource
        
//        picker.frame = CGRect(x: 0, y: 0, width: self.pickerContainer.bounds.width, height: self.pickerContainer.bounds.height)
//        self.pickerContainer.addSubview(self.picker)
        
        self.dataSource.output = self
        self.userRegistrationTable.dataSource = self.dataSource
        self.userRegistrationTable.delegate = self.dataSource
        self.output.prepareCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userRegistrationTable.register(UINib(nibName: "inputCell", bundle: nil), forCellReuseIdentifier: "BaseUserInputCellViewID")
        self.userRegistrationTable.register(UINib(nibName: "GSMUInputCell", bundle: nil), forCellReuseIdentifier: "GSMUserInputCellID")
        self.userRegistrationTable.register(UINib(nibName: "PasswordCell", bundle: nil), forCellReuseIdentifier: "PasswordCellID")
//        self.setupConstraintsForPicker()
    }
    
    private func setupConstraintsForPicker() {

//        let firstView = self.picker.pickerView//self.pickerContainer
//        let secondView = self.pickerContainer//self.picker.superview
//        let topConstraint = NSLayoutConstraint(item: firstView,
//                                               attribute: .top,
//                                               relatedBy: .equal,
//                                               toItem: secondView,
//                                               attribute: .top,
//                                               multiplier: 1,
//                                               constant: 0)
//        let botConstraint = NSLayoutConstraint(item: firstView,
//                                               attribute: .bottom,
//                                               relatedBy: .equal,
//                                               toItem: secondView,
//                                               attribute: .bottom,
//                                               multiplier: 1,
//                                               constant: 0)
//        let leadingConstraint = NSLayoutConstraint(item: firstView,
//                                               attribute: .leading,
//                                               relatedBy: .equal,
//                                               toItem: secondView,
//                                               attribute: .leading,
//                                               multiplier: 1,
//                                               constant: 0)
//        let trailingConstraint = NSLayoutConstraint(item: firstView,
//                                               attribute: .trailing,
//                                               relatedBy: .equal,
//                                               toItem: secondView,
//                                               attribute: .trailing,
//                                               multiplier: 1,
//                                               constant: 0)
//        self.picker.addConstraint(trailingConstraint)
////        self.picker.addConstraints([topConstraint, botConstraint, leadingConstraint, trailingConstraint])
        
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
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func nextActionHandler(_ sender: Any) {
        guard let navController = self.navigationController else {
            return
        }
        self.output.nextButtonPressed(withNavController: navController, email: self.getTextFieldValue(forRow: 0), phone: self.getTextFieldValue(forRow: 1), password: self.getTextFieldValue(forRow: 2), repassword: self.getTextFieldValue(forRow: 3))
    }
    
    private func getTextFieldValue(forRow: Int) -> String {
        guard let cell = self.userRegistrationTable.cellForRow(at: IndexPath(item: forRow, section: 0)) else {
            return ""
        }
        if let cell = cell as? GSMUserInputCell {
            let gsmCodeWithPhone = self.dataSource.getGSMCode(forRow: forRow) + cell.textInputField.text!
            return gsmCodeWithPhone
        }
        if let cell = cell as? BaseUserInputCellView {
            return cell.textInputField.text!
        }

        return ""
    }
    
    func prepareNavController() {
        guard let navController = self.navigationController else {
            return
        }
        self.output.readyForPassing(withNavController: navController)
    }
    
    //MARK: - DataSource output
    @IBAction func pickerChoosePressed(_ sender: Any) {
//        self.view
        self.pickerBottomConstraint.constant = -271
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
            
        })
       
//        self.view.layoutIfNeeded()
        let currentRow = self.pickerView.selectedRow(inComponent: 0)
        self.dataSource.changeGSMCodeLabel(withRow: currentRow)
        self.userRegistrationTable.reloadRows(at: [IndexPath(item: 1, section: 0)], with: UITableViewRowAnimation.none)
//        self.dataSource.current
        
    }
    func pickerGotTapped() {
        self.pickerBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

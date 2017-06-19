//
//  RegistrationRegistrationViewController.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, RegistrationViewInput, DataSourceOutput {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var userRegistrationTable: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var output: RegistrationViewOutput!
    let dataSource = RegistrationDataSource()

    var isPickerTapped = false
    
    @IBOutlet weak var pickerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    @IBOutlet weak var pickerContainer: UIView!
    private var originBottomH:CGFloat = -1
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = TextConstants.registerTitle
        self.nextBtn.setTitleColor(ColorConstants.blueColor, for: .normal)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyBoard),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        self.setupDelegates()
        self.output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.userRegistrationTable.register(UINib(nibName: "inputCell", bundle: nil),
                                            forCellReuseIdentifier: CellsIdConstants.baseUserInputCellViewID)
        self.userRegistrationTable.register(UINib(nibName: "GSMUInputCell", bundle: nil),
                                            forCellReuseIdentifier: CellsIdConstants.gSMUserInputCellID)
        self.userRegistrationTable.register(UINib(nibName: "PasswordCell", bundle: nil),
                                            forCellReuseIdentifier: CellsIdConstants.passwordCellID)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        originBottomH = bottomConstraint.constant
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    private func setupDelegates() {
        self.pickerView.dataSource = self.dataSource
        self.pickerView.delegate = self.dataSource
        
        self.dataSource.output = self
        self.userRegistrationTable.dataSource = self.dataSource
        self.userRegistrationTable.delegate = self.dataSource
    }
    
    func showKeyBoard(notification: NSNotification){
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        let tableH = scrollView.frame.origin.y + userRegistrationTable.frame.size.height
        let dy = view.frame.size.height - tableH
        if (dy < keyboardHeight){
            let increaseH = abs((view.frame.size.height - keyboardHeight) - tableH)
            bottomConstraint.constant = increaseH + originBottomH
            view.layoutIfNeeded()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hideKeyboard()
        self.hidePicker()
    }
    
    private func hideKeyboard() {
        view.endEditing(true)
        bottomConstraint.constant = originBottomH
        self.view.layoutIfNeeded()
    }
    
    private func handleNextAction() {
//        guard let navController = self.navigationController else {
//            return
//        }
//        self.output.nextButtonPressed(withNavController: navController, email: self.getTextFieldValue(forRow: 0), phone: self.getTextFieldValue(forRow: 1), password: self.getTextFieldValue(forRow: 2), repassword: self.getTextFieldValue(forRow: 3))
    }
    
    private func reloadGSMCell() {
        self.userRegistrationTable.reloadRows(at: [IndexPath(item: 1, section: 0)], with: UITableViewRowAnimation.none)
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
        if let cell = cell as? PasswordCell {
            return cell.textInput.text!
        }
        
        return ""
    }
    
    private func findNextProtoCell(fromEditedCell editedCell: ProtoInputTextCell) {
        if AutoNextEditingRowPasser.passToNextEditingRow(withEditedCell: editedCell, inTable: self.userRegistrationTable) == nil {
            self.handleNextAction()
        }
    }
    
    private func hidePicker() {
        self.shadowView.isHidden = true
        self.shadowView.isUserInteractionEnabled = false
        self.pickerBottomConstraint.constant = -271
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
            
        })
    }
    
    private func showPicker() {
        self.shadowView.isHidden = false
        self.shadowView.isUserInteractionEnabled = true
        self.pickerBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func pickerGotTapped() {
        self.hideKeyboard()
        self.showPicker()
    }
    
    // MARK: - Actions
    @IBAction func nextActionHandler(_ sender: Any) {
//        self.handleNextAction()
        self.output.nextButtonPressed()
    }
    
    @IBAction func pickerChoosePressed(_ sender: Any) {
        self.hidePicker()
        let currentRow = self.pickerView.selectedRow(inComponent: 0)
        self.dataSource.changeGSMCodeLabel(withRow: currentRow)
        self.reloadGSMCell()
    }
    
    @IBAction func onHideKeyBoard(){
        self.hideKeyboard()
    }
    
    
    // MARK: RegistrationViewInput

    func setupRow(forRowIdex rowIndex: Int, withTitle title: String) {
        //setup row
    }
    
    func setupInitialState(withModels: [BaseCellModel]) {
        self.shadowView.isHidden = true //TODO: create in popup service something like "show shadow view"
        self.shadowView.isUserInteractionEnabled = false
        self.dataSource.setupCells(withModels: withModels)
        self.userRegistrationTable.reloadData()
    }
    
    func setupPicker(withModels: [GSMCodeModel]) {
        self.dataSource.setupPickerCells(withModels: withModels)
        self.pickerView.reloadAllComponents()
    }
    
    func setupCurrentGSMCode(toGSMCode gsmCode: String) {
        self.dataSource.changeGSMCode(withCode: gsmCode)
        self.reloadGSMCell()
    }

    func prepareNavController() {
        guard let navController = self.navigationController else {
            return
        }
        self.output.readyForPassing(withNavController: navController)
    }
    
    func collectInputedUserInfo() {
        self.output.collectedUserInfo(email: self.getTextFieldValue(forRow: 0), phone: self.getTextFieldValue(forRow: 1), password: self.getTextFieldValue(forRow: 2), repassword: self.getTextFieldValue(forRow: 3))
    }
    
    //MARK: - DataSource output
    func protoCellTextFinishedEditing(cell: ProtoInputTextCell) {
        self.findNextProtoCell(fromEditedCell: cell)
    }
    
    func protoCellTextStartedEditing(cell: ProtoInputTextCell) {
        self.hidePicker()
    }
}

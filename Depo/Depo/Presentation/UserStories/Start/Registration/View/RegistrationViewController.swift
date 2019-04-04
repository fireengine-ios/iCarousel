//
//  RegistrationRegistrationViewController.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol RegistrationViewDelegate: class {
    func show(errorString: String)
    func showCaptcha()
}

class RegistrationViewController: ViewController {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var userRegistrationTable: UITableView!
    @IBOutlet weak var nextBtn: WhiteButtonWithRoundedCorner!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var iPadTitleLabel: UILabel!
    
    @IBOutlet weak var spaceBetweenNextButtonAndTable: NSLayoutConstraint!
    
    var output: RegistrationViewOutput!
    let dataSource = RegistrationDataSource()

    @IBOutlet weak var pickerContainer: UIView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var pickerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var captchaContainer: UIView!
    
    @IBOutlet weak var captchaContainerHeightConstraint: NSLayoutConstraint!
    
    private var captchaController: CaptchaViewController?
    
    private var originBottomH: CGFloat = -1
    private var originSpaceBetweenNextButtonAndTable: CGFloat = -1
    
    private let erroredSpaceBetweenNextButtonAndTable: CGFloat = 20
    
    private let captchaContainerHeight: CGFloat = 150
    private var isCaptchaVisible = false
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Device.isIpad {
            setNavigationTitle(title: TextConstants.registerTitle)
        }
        
        errorLabel.text = ""
        errorLabel.textColor = ColorConstants.yellowColor
        errorLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
        if (Device.isIpad) {
            navigationItem.title = ""
            iPadTitleLabel.text = TextConstants.registrationTitleText
            iPadTitleLabel.font = UIFont.TurkcellSaturaDemFont(size: 22)
            errorLabel.font = UIFont.TurkcellSaturaMedFont(size: 22)
        }
        
        iPadTitleLabel.textColor = ColorConstants.whiteColor
        
        nextBtn.setTitle(TextConstants.registrationNextButtonText, for: .normal)

        backButtonForNavigationItem(title: TextConstants.backTitle)

        
        let doneButton = UIBarButtonItem(title: TextConstants.chooseTitle,
                                         target: self,
                                         selector: #selector(donePicker(sender:)))
        doneButton.tintColor = UIColor.blue
        
        let pickerToolBar = barButtonItemsWithRitht(button: doneButton)
        
        pickerContainer.addSubview(pickerToolBar)

        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboardAndPicker)))
        
        setupDelegates()
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hidenNavigationBarStyle()
        
        userRegistrationTable.register(UINib(nibName: "inputCell", bundle: nil),
                                       forCellReuseIdentifier: CellsIdConstants.baseUserInputCellViewID)
        userRegistrationTable.register(UINib(nibName: "GSMUInputCell", bundle: nil),
                                       forCellReuseIdentifier: CellsIdConstants.gSMUserInputCellID)
        userRegistrationTable.register(UINib(nibName: "PasswordCell", bundle: nil),
                                       forCellReuseIdentifier: CellsIdConstants.passwordCellID)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyBoard),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        view.layoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        originBottomH = bottomConstraint.constant
        originSpaceBetweenNextButtonAndTable = spaceBetweenNextButtonAndTable.constant
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - IBActions
    
    @IBAction func nextActionHandler(_ sender: Any) {
        handleNextAction()
    }
    
    // MARK: - Actions
    
    @objc func donePicker(sender: AnyObject) {
        chooseButtonPressed()
    }
    
    private func refreshCaptcha() {
        captchaController?.refreshCapthcha()
        captchaController?.inputTextField.text = ""
    }
    
    private func setupConstraintsForCaptchaVC() {
        captchaController?.view.frame = captchaContainer.bounds
    }
    
    func changeErrorLabelAppearance(status: Bool) {
        if status {
            hideKeyboardAndPicker()
        } else {
            errorLabel.text = ""
        }
        view.updateConstraints()
        view.layoutIfNeeded()
    }
    
    private func setupDelegates() {
        pickerView.dataSource = dataSource
        pickerView.delegate = dataSource
        
        dataSource.output = self
        userRegistrationTable.dataSource = dataSource
        userRegistrationTable.delegate = dataSource
    }
    
    func setScrollViewOffsetForErrorIfNeed() {
        let isErrorLabelVisible = scrollView.contentOffset.y > errorLabel.frame.origin.y
        
        if isErrorLabelVisible {
            scrollView.setContentOffset(CGPoint(x: 0, y: errorLabel.frame.origin.y), animated: true)
        }
    }
    
    @objc func showKeyBoard(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        let yNextButton = getMainYForView(view: nextBtn) + nextBtn.frame.size.height
        if (view.frame.size.height - yNextButton < keyboardHeight) {
            
            bottomConstraint.constant = keyboardHeight + 40.0
            spaceBetweenNextButtonAndTable.constant = 5.0
            view.layoutIfNeeded()
            
            let textField = searchActiveTextField(view: self.view)
            if (textField != nil) {
                var yOfTextField = getMainYForView(view: textField!) + textField!.frame.size.height + 20
                if (textField!.tag == 33) {
                    yOfTextField = getMainYForView(view: nextBtn) + nextBtn.frame.size.height
                }
                if (yOfTextField > view.frame.size.height - keyboardHeight) {
                    let dy = yOfTextField - (view.frame.size.height - keyboardHeight)
                    
                    let point = CGPoint(x: 0, y: dy + 10)
                    scrollView.setContentOffset(point, animated: true)
                }
            }
        }
    }

    private func searchActiveTextField(view: UIView) -> UITextField? {
        if let textField = view as? UITextField {
            if textField.isFirstResponder {
                return textField
            }
        }
        for subView in view.subviews {
            let textField = searchActiveTextField(view: subView)
            if (textField != nil) {
                return textField
            }
        }
        return nil
    }
    
    private func getMainYForView(view: UIView) -> CGFloat {
        if (view.superview == self.view) {
            return view.frame.origin.y
        } else {
            if (view.superview != nil) { 
                return view.frame.origin.y + getMainYForView(view: view.superview!)
            } else {
                return 0
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboardAndPicker()
    }
    
    @objc private func hideKeyboardAndPicker() {
        hideKeyboard()
        hidePicker()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
        bottomConstraint.constant = originBottomH
        
        spaceBetweenNextButtonAndTable.constant = errorLabel.text!.isEmpty ? originSpaceBetweenNextButtonAndTable : erroredSpaceBetweenNextButtonAndTable
        view.layoutIfNeeded()
    }
    
    private func reloadGSMCell() {
        userRegistrationTable.reloadRows(at: [IndexPath(item: 0, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    private func getTextFieldValue(forRow: Int) -> String {
        guard let cell = userRegistrationTable.cellForRow(at: IndexPath(item: forRow, section: 0)) else {
            return ""
        }
        if let cell = cell as? GSMUserInputCell {
            let gsmCodeWithPhone = /*dataSource.currentGSMCode*//*getGSMCode(forRow: forRow)*/  cell.textInputField.text!
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
     _ = AutoNextEditingRowPasser.passToNextEditingRow(withEditedCell: editedCell, inTable: userRegistrationTable)
    }
    
    private func hidePicker() {
        changePickerState(state: false)
    }
    
    private func showPicker() {
        changePickerState(state: true)
    }
    
    private func changePickerState(state isActive: Bool) {
        shadowView.isHidden = !isActive
        shadowView.isUserInteractionEnabled = isActive
        if isActive {
            pickerBottomConstraint.constant = 0
        } else {
            pickerBottomConstraint.constant = -271
        }
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func pickerGotTapped() {
        hideKeyboard()
        showPicker()
    }
    
    private func handleNextAction() {
        hideKeyboardAndPicker()
        output.nextButtonPressed()
    }
    
    private func setupInitialtGSMCode() {
        let telephonyService = CoreTelephonyService()
        let phoneCode = telephonyService.callingCountryCode()
        if phoneCode == "" || UIDevice.current.modelName == "iPad Pro 12.9 Inch 2. Generation" || UIDevice.current.modelName == "iPad Pro 10.5 Inch" || UIDevice.current.modelName == "iPad Pro 9.7 Inch"{
            self.dataSource.currentGSMCode = telephonyService.countryCodeByLang()
        }
    }
    
    // MARK: - Picker Choose
    
    func chooseButtonPressed() {
        hidePicker()
        let currentRow = pickerView.selectedRow(inComponent: 0)
        dataSource.changeGSMCodeLabel(withRow: currentRow)
        reloadGSMCell()
    }
}

// MARK: - RegistrationViewInput

extension RegistrationViewController: RegistrationViewInput {
    func setupInitialState(withModels: [BaseCellModel]) {
        shadowView.isHidden = true //TODO: create in popup service something like "show shadow view"
        shadowView.isUserInteractionEnabled = false
        dataSource.setupCells(withModels: withModels)
        setupInitialtGSMCode()
        userRegistrationTable.reloadData()
    }
    
    func setupPicker(withModels: [GSMCodeModel]) {
        dataSource.setupPickerCells(withModels: withModels)
        pickerView.reloadAllComponents()
    }
    
    func setupCurrentGSMCode(toGSMCode gsmCode: String) {
        dataSource.changeGSMCode(withCode: gsmCode)
        reloadGSMCell()
    }
    
    func collectInputedUserInfo() {
        output.collectedUserInfo(email: getTextFieldValue(forRow: 1), code: dataSource.currentGSMCode, phone: getTextFieldValue(forRow: 0), password: getTextFieldValue(forRow: 2), repassword: getTextFieldValue(forRow: 3), captchaID: captchaController?.getCaptchaID(), captchaAnswer: captchaController?.getCaptchaAnswer())
    }
    
    func showInfoButton(forType type: UserValidationResults) {
        var textCell: ProtoInputTextCell?
        switch type {//FIXME: change it to more reasanble way 
        case .mailIsEmpty:
            textCell = userRegistrationTable.cellForRow(at: IndexPath(item: 1, section: 0)) as? BaseUserInputCellView
        case .passwordIsEmpty:
            textCell = userRegistrationTable.cellForRow(at: IndexPath(item: 2, section: 0)) as? PasswordCell
        case .phoneIsEmpty:
            textCell = userRegistrationTable.cellForRow(at: IndexPath(item: 0, section: 0)) as? GSMUserInputCell
        case .repasswordIsEmpty:
            textCell = userRegistrationTable.cellForRow(at: IndexPath(item: 3, section: 0)) as? PasswordCell
        default:
            break
        }
        if let textCell = textCell {
            textCell.changeInfoButtonTo(hidden: false)
        }
    }
    
    func showErrorTitle(withText: String) {
        setScrollViewOffsetForErrorIfNeed()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        errorLabel.attributedText = NSAttributedString(string: withText, attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle])
        changeErrorLabelAppearance(status: true)
        //        if (Device.isIpad){
        //          errorLabelHeight.constant = errorLabelConstraintOriginalHeight * 1.5
        //        }
        
        if isCaptchaVisible {
            refreshCaptcha()
        }
    }
    
    func setupCaptchaVC(captchaVC: CaptchaViewController) {
        if isCaptchaVisible {
            return
        }
        isCaptchaVisible = true
        
        captchaContainerHeightConstraint.constant = captchaContainerHeight
        captchaController = captchaVC
        captchaContainer.addSubview(captchaVC.view)
        
        setupConstraintsForCaptchaVC()
    }
}

// MARK: - DataSource output

extension RegistrationViewController: DataSourceOutput {
    
    func protoCellTextFinishedEditing(cell: ProtoInputTextCell) {
        findNextProtoCell(fromEditedCell: cell)
    }
    
    func protoCellTextStartedEditing(cell: ProtoInputTextCell) {
        changeErrorLabelAppearance(status: false)
        hidePicker()
    }
    
    func infoButtonGotPressed(withType: UserValidationResults) {
        output.infoButtonGotPressed(with: withType)
    }
}

extension RegistrationViewController: RegistrationViewDelegate {
    func show(errorString: String) {
        showErrorTitle(withText: errorString)
    }
    func showCaptcha() {
        output.captchaRequred(requred: true)
    }
}



//
//  TextEnterController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/9/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

typealias TextEnterHandler = (_ text: String, _ vc: TextEnterController) -> Void

final class TextEnterController: ViewController, NibInit {
    
    var output: RegistrationViewOutput!
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var pickerContainer: UIView!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var pickerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var changeButton: BlueButtonWithWhiteText! {
        didSet {
            changeButton.isExclusiveTouch = true
            changeButton.setTitle(doneButtonTitle, for: .normal)
        }
    }
    
    
    private let dataSource = TextEnterDataSource()
    private let gsmCompositor = CounrtiesGSMCodeCompositor()
    private let dataStorage = DataStorage()
    
    private var alertTitle = ""
    private var doneButtonTitle = ""
    private var textPlaceholder: String?
    
    private lazy var doneAction: TextEnterHandler = { [weak self] _, _ in
        self?.close(completion: nil)
    }
    
    private var phone: String? {
        guard
            let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? GSMUserInputCell,
            let code = cell.gsmCountryCodeLabel.text,
            let number = cell.inputTextField?.text
        else {
            return nil
        }
        return code + number
    }
    
    // MAKR: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = alertTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.exitWhite, style: .plain, target: self, action: #selector(dismiss))
        
        shadowView.isHidden = true
        shadowView.isUserInteractionEnabled = false
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    private func setupDelegates() {
        dataSource.setupCells(withModels: dataStorage.getModels())
        dataSource.setupPickerCells(withModels: gsmCompositor.getGSMCCModels())
        dataSource.output = self
        
        tableView.register(UINib(nibName: "GSMUInputCell", bundle: nil), forCellReuseIdentifier: CellsIdConstants.gSMUserInputCellID)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        let doneButton = UIBarButtonItem(title: TextConstants.chooseTitle,
                                         style: .plain,
                                         target: self,
                                         action: #selector(donePicker))
        let pickerToolBar = barButtonItemsWithRitht(button: doneButton)
        pickerContainer.addSubview(pickerToolBar)
        pickerView.dataSource = dataSource
        pickerView.delegate = dataSource
    }

    func showAlertMessage(with text: String) {
        showAlertMessage(with: text)
    }

    func startLoading() {
        showSpiner()
    }

    func stopLoading() {
        hideSpiner()
    }
       
    // MARK: - Actions
    
    @IBAction func change(_ sender: UIButton) {
        if verifyPhone() {
            doneAction(phone ?? "", self)
        }
    }
    
    @objc private func dismiss(_ sender: UIBarButtonItem) {
        close(completion: nil)
    }
    
    @objc func close(completion: VoidHandler? = nil) {
        view.endEditing(true)
        dismiss(animated: true, completion: completion)
    }
    
    @objc func donePicker() {
        chooseButtonPressed()
    }
    
    private func verifyPhone() -> Bool {
        guard let phone = phone?.replacingOccurrences(of: "+", with: "") else {
            return false
        }

        guard phone.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
            return false
        }
        
        guard phone.count > 8 else {
            return false
        }
        
        return true
    }
    
    // MARK: - Picker
    
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
    
    func chooseButtonPressed() {
        hidePicker()
        let currentRow = pickerView.selectedRow(inComponent: 0)
        dataSource.changeGSMCodeLabel(withRow: currentRow)
        tableView.reloadData()
    }
}

extension TextEnterController: DataSourceOutput {
    func pickerGotTapped() {
        view.endEditing(true)
        showPicker()
    }
    
    func protoCellTextFinishedEditing(cell: ProtoInputTextCell) {
        
    }
    
    func protoCellTextStartedEditing(cell: ProtoInputTextCell) {
        hidePicker()
    }
    
    func infoButtonGotPressed(withType: UserValidationResults) {

    }
}

// MARK: - Static
extension TextEnterController {
    
    static func with(title: String, buttonTitle: String, buttonAction: TextEnterHandler? = nil) -> TextEnterController {
        
        let vc = TextEnterController.initFromNib()
        vc.alertTitle = title
        vc.doneButtonTitle = buttonTitle
        
        if let action = buttonAction {
            vc.doneAction = action
        }
        
        return vc
    }
}

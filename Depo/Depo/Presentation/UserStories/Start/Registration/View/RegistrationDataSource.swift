//
//  RegisterDataSource.swift
//  Depo
//
//  Created by Aleksandr on 6/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol DataSourceOutput {
    func pickerGotTapped()
    func protoCellTextFinishedEditing(cell: ProtoInputTextCell)
    func protoCellTextStartedEditing(cell: ProtoInputTextCell)
    
    func infoButtonGotPressed(withType: UserValidationResults)
}

class RegistrationDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    var output: DataSourceOutput?
    var cells: [BaseCellModel] = []
    var gsmModels: [GSMCodeModel] = []
    var currentGSMCode = CoreTelephonyService().callingCountryCode()
    var currentPhoneNumber = ""
    
    func setupCells(withModels models: [BaseCellModel]) {
        
        cells.removeAll()
        cells.append(contentsOf: models)
    }
    
    func setupPickerCells(withModels models: [GSMCodeModel]) {
        gsmModels.removeAll()
        gsmModels.append(contentsOf: models)
    }
    
    func changeGSMCodeLabel(withRow row: Int) {
        let gsmModel = gsmModels[row]
        currentGSMCode = gsmModel.gsmCode
    }
    
    func changeGSMCode(withCode code: String) {
        currentGSMCode = code
        //TOFO: setup picker here on row with taht code
        
    }
    
    func getGSMCode(forRow row: Int) -> String {
        let gsmModel = gsmModels[row]
        return gsmModel.gsmCode
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tempoRow: UITableViewCell
        
        if indexPath.row == 0 {
            tempoRow = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.gSMUserInputCellID, for: indexPath)
        } else if indexPath.row == 1 {
            tempoRow = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.baseUserInputCellViewID,
                                                     for: indexPath)
        } else {
            tempoRow = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.passwordCellID,
                                                     for: indexPath)
        }
        
        setupCell(withCell: tempoRow, atIndex: indexPath.row)
        
        return tempoRow
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.needsUpdateConstraints()
        cell.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    private func setupCell(withCell cell: UITableViewCell, atIndex index: Int) {

        guard let cell = cell as? ProtoInputTextCell, cells.count > 0  else {
            return
        }
        cell.textDelegate = self
        let model = cells[index]
        
        if let cell = cell as? BaseUserInputCellView {
            cell.infoButtonDelegate = self
            cell.setupBaseCell(withTitle: model.title, inputText: model.inputText)
            
            #if DEBUG
                cell.inputTextField?.text = "testMail@notRealMail.yep"
            #endif
            
            if let cell = cell as? GSMUserInputCell {
                cell.delegate = self
                cell.setupGSMCode(code: currentGSMCode)
                cell.inputTextField?.text = currentPhoneNumber //model.inputText
                #if DEBUG
                    cell.inputTextField?.text = "259092538"
                    cell.gsmCountryCodeLabel.text = "+375"
                    currentGSMCode = "+375"
                #endif
            }
        } else if let cell = cell as? PasswordCell {
            cell.infoButtonDelegate = self
            cell.setupInitialState(withLabelTitle: model.title, placeHolderText: model.inputText)
            if index == 3 {
                cell.type = PasswordCell.PasswordCellType.reEnter
                cell.textInput.tag = 33
            }
            #if DEBUG
                cell.inputTextField?.text = ".FsddQ646"
            #endif
        }
    }
}

extension RegistrationDataSource: UIPickerViewDataSource, UIPickerViewDelegate, ProtoInputCellProtocol, GSMCodeCellDelegate, InfoButtonCellProtocol {
    
    func codeViewGotTapped() {
        output?.pickerGotTapped()
    }
    
    func phoneNumberChanged(toNumber number: String) {
//        let phoneNumber = number.count > 0 ? number : TextConstants.registrationCellPlaceholderPhone
//        let oldPhoneModel = cells[0]
//        let newPhoneModel = BaseCellModel(withTitle: oldPhoneModel.title, initialText: phoneNumber)
//        cells[0] = newPhoneModel
        currentPhoneNumber = number
    }
    
    func textFinishedEditing(withCell cell: ProtoInputTextCell) {
        output?.protoCellTextFinishedEditing(cell: cell)
    }

    func textStartedEditing(withCell cell: ProtoInputTextCell) {
        output?.protoCellTextStartedEditing(cell: cell)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gsmModels.count
    }
        
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var pickerTitle = ""
        if !gsmModels.isEmpty {
            let model = gsmModels[row]
            pickerTitle = model.gsmCode + "    " + model.countryName
        }        
        return NSAttributedString(string: pickerTitle, attributes: [.foregroundColor: UIColor.black])
    }
    
    func infoButtonGotPressed(with sender: Any?, andType type: UserValidationResults) {
        var errorType = type
        if let cell = sender as? PasswordCell, cell.type == .reEnter {
            errorType = .passwodsNotMatch
        }
        
        output?.infoButtonGotPressed(withType: errorType)
    }
    
    
}

//
//  LoginDataSource.swift
//  Depo
//
//  Created by Oleg on 13.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol LoginDataSourceActionsDelegate: class {
    func textStrtedEditing()
    func loginCellFistEnteringPhonePlus()
    func loginCellFistEnteringPhone()
}

class LoginDataSource: NSObject, UITableViewDelegate, UITableViewDataSource, ProtoInputCellProtocol, LoginPhoneMailCellActionProtocol {
    
    func firstCharacterIsPlus(fromCell cell: LoginPhoneMailCell, string: String) {
        actionsDelegate?.loginCellFistEnteringPhonePlus()
    }
    
    func firstCharacterIsNum(fromCell cell: LoginPhoneMailCell, string: String) {
        actionsDelegate?.loginCellFistEnteringPhone()
    }
    
    func textStartedEditing(withCell cell: ProtoInputTextCell) {
        actionsDelegate?.textStrtedEditing()
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    var tableDataMArray: [BaseCellModel] = []
    
    weak var actionsDelegate: LoginDataSourceActionsDelegate?
    
    func setupTableView(tableView: UITableView) {
        self.tableView = tableView
//        var nib = UINib(nibName: "inputCell", bundle: nil)
//        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.baseUserInputCellViewID)
        
        var nib = UINib(nibName: "LoginPhoneMailCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.loginPhoneMailCellID)
        
        nib = UINib(nibName: "PasswordCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.passwordCellID)
    }
    
    func setupCellsWithModels(models: [BaseCellModel]) {
        tableDataMArray.removeAll()
        tableDataMArray.insert(contentsOf: models, at: 0)
        tableView.reloadData()
    }

    //MARC: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataMArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 101
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.loginPhoneMailCellID, for: indexPath) as! LoginPhoneMailCell
            cell.loginCellActionDelegate = self
            let model = tableDataMArray[indexPath.row]
            cell.setupBaseCell(withTitle: model.title, inputText: model.inputText)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.textDelegate = self
            
            #if DEBUG
                cell.textInputField.text = "+375447394882"//"qwerty@my.com"// "test3@test.test"//"test2@test.test"//"testasdasdMail@notRealMail.yep"
            #endif

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.passwordCellID,
                                                     for: indexPath) as! PasswordCell
            let model = tableDataMArray[indexPath.row]
            cell.setupInitialState(withLabelTitle: model.title, placeHolderText: model.inputText)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textInput.tag = 33
            cell.textDelegate = self
            #if DEBUG
                cell.textInput.text = "qazwsx"//"qwerty"// "zxcvbn"//".FsddQ646"
            #endif
            return cell
        }
    }
    
    // MARK: ProtoInputCellProtocol
    
    func textFinishedEditing(withCell cell: ProtoInputTextCell) {
        _ = AutoNextEditingRowPasser.passToNextEditingRow(withEditedCell: cell, inTable: tableView)
    }
    
    func getLogin() -> String {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let baseCell = cell as! BaseUserInputCellView
        return baseCell.textInputField?.text ?? ""
    }
    
    func getPassword() -> String {
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        let baseCell = cell as! PasswordCell
        return baseCell.textInput.text ?? ""
    }
}

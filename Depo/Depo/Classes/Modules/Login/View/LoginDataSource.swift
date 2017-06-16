//
//  LoginDataSource.swift
//  Depo
//
//  Created by Oleg on 13.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class LoginDataSource: NSObject, UITableViewDelegate, UITableViewDataSource, ProtoInputCellProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    var tableDataMArray: [BaseCellModel] = []
    
    
    func setupTableView(tableView: UITableView){
        self.tableView = tableView
        var nib = UINib(nibName: "inputCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.baseUserInputCellViewID)
        
        nib = UINib(nibName: "PasswordCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.passwordCellID)
    }
    
    func setupCellsWithModels(models:[BaseCellModel]){
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
        return 81.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.baseUserInputCellViewID, for: indexPath) as! BaseUserInputCellView
            let model = tableDataMArray[indexPath.row]
            cell.titleLabel.text = model.title
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textInputField.attributedPlaceholder = NSAttributedString(string: model.inputText, attributes: [NSForegroundColorAttributeName: ColorConstants.whiteColor])
            
            cell.textDelegate = self
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.passwordCellID,
                                                     for: indexPath) as! PasswordCell
            let model = tableDataMArray[indexPath.row]
            cell.titleLabel.text = model.title
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textInput.text = model.inputText
            
            cell.textDelegate = self
            
            return cell
        }
        
    }
    
    // MARK: ProtoInputCellProtocol
    
    func textFinishedEditing(withCell cell: ProtoInputTextCell){
        AutoNextEditingRowPasser.passToNextEditingRow(withEditedCell: cell, inTable: tableView)
        
    }
    
}

//
//  RegisterDataSource.swift
//  Depo
//
//  Created by Aleksandr on 6/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol DataSourceOutput {
//    func userDidTapCell(forIndex: Int)
    func pickerGotTapped()
}

class RegistrationDataSource: NSObject, UITableViewDelegate, UITableViewDataSource, GSMCodeCellDelegate {
    var output: DataSourceOutput? = nil
    var cells: [BaseCellModel] = []
    var gsmModels: [GSMCodeModel] = []
    var currentGSMCode = "+376"
    
    func setupCells(withModels models: [BaseCellModel]) {
        cells.removeAll()
        cells.append(contentsOf: models)
    }
    
    func setupPickerCells(withModels models: [GSMCodeModel]) {
        gsmModels.removeAll()
        gsmModels.append(contentsOf: models)
    }
    
    func changeGSMCodeLabel(withRow row: Int) {
        let gsmModel = self.gsmModels[row]
        self.currentGSMCode = gsmModel.code
        
    }
    func getGSMCode(forRow row: Int) -> String {
        let gsmModel = self.gsmModels[row]
        return gsmModel.code
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100//self.output.getRowHeight(forIndex: indexPath.row)
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tempoRow: UITableViewCell
        if indexPath.row == 1 {
            tempoRow = tableView.dequeueReusableCell(withIdentifier: "GSMUserInputCellID", for: indexPath)
        } else {
            tempoRow = tableView.dequeueReusableCell(withIdentifier: "BaseUserInputCell", for: indexPath)
        }
        
        self.setupCell(withCell: tempoRow, atIndex: indexPath.row)
        
        return tempoRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    private func setupCell(withCell cell: UITableViewCell, atIndex index: Int) {
        if let cell = cell as? GSMUserInputCell {
            cell.delegate = self
            cell.setupGSMCode(code: currentGSMCode)
        }
        guard let cell = cell as? BaseUserInputCellView else {
            return
        }
        if cells.count > 0 {
            let model = cells[index]
            cell.setupCell(withTitle: model.title, inputText: model.inputText, cellType: model.type)
        }
    }
    
    func codeViewGotTapped() {
        self.output?.pickerGotTapped()
        
    }
    
}

extension RegistrationDataSource: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.gsmModels.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard self.gsmModels.count > 0 else {
            return ""
        }
        let model = gsmModels[row]
        let pickerTitle = model.code + "    " + model.countryName
        return pickerTitle
    }
}

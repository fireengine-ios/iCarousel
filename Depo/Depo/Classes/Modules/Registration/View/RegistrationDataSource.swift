//
//  RegisterDataSource.swift
//  Depo
//
//  Created by Aleksandr on 6/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class RegistrationDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    var cells: [BaseCellModel] = []
    
    func setupCells(withModels models: [BaseCellModel]) {
        cells.append(contentsOf: models)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100//self.output.getRowHeight(forIndex: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tempoRow = tableView.dequeueReusableCell(withIdentifier: "BaseUserInputCell", for: indexPath)
        self.setupCell(withCell: tempoRow, atIndex: indexPath.row)
        
        return tempoRow
    }
    
    private func setupCell(withCell cell: UITableViewCell, atIndex index: Int) {
//        if let cell = cell as? BaseUserInputCellView {
//            debugPrint("cell is ", cell)
//        } else if let cell = cell as? GSMUserInputCell {
//            debugPrint("cell is ", cell)
//        }
        guard let cell = cell as? BaseUserInputCellView else {
            return
        }
        if cells.count > 0 {
            let model = cells[index]
//            cell.titleLabel.text = model.title
//            cell.textInputField.text = model.inputText
            cell.setupCell(withTitle: model.title, inputText: model.inputText, cellType: model.type)
        }
    }
}

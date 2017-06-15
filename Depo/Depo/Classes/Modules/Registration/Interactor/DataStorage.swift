//
//  DataStorage.swift
//  Depo
//
//  Created by Aleksandr on 6/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class DataStorage {
    
    let numberOfModels = 4
    let titles = [TextConstants.registrationCellTitleEmail,
                  TextConstants.registrationCellTitleGSMNumber,
                  TextConstants.registrationCellTitlePassword,
                  TextConstants.registrationCellInitialTextReFillPassword]
    let initialTexts = [TextConstants.registrationCellInitialTextEmail,
                        "",
                        TextConstants.registrationCellInitialTextFillPassword,
                        TextConstants.registrationCellInitialTextReFillPassword]
    
    let cellTypes: [CellTypes] = [.base, .phone, .base, .base]
    
    var models: [BaseCellModel] = []
    var gsmModels: [GSMCodeModel] = []
    
    
    func getModels() -> [BaseCellModel] {
        if self.models.count == 0 {
            self.createInitialStateModels()
        }
        return models
    }
    
    func configurateModel(forIndex index: Int, withValue value: String) {
        let model = models[index]
        model.inputText = value
        debugPrint("models are ", self.models)
    }
    
    private func createInitialStateModels() {
        for i in 0..<numberOfModels {
            models.append(BaseCellModel(withTitle: titles[i], initialText: initialTexts[i], cellType: cellTypes[i]))
        }
    }
    
}

//
//  DataStorage.swift
//  Depo
//
//  Created by Aleksandr on 6/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class DataStorage {
    
    var models: [BaseCellModel] = []
    var gsmModels: [GSMCodeModel] = []
    
    init() {
        models = [BaseCellModel(withTitle: TextConstants.registrationCellTitleEmail,
                                initialText: TextConstants.registrationCellInitialTextEmail),
        BaseCellModel(withTitle: TextConstants.registrationCellTitleGSMNumber,
                      initialText: ""),
        BaseCellModel(withTitle: TextConstants.registrationCellTitlePassword,
                      initialText: TextConstants.registrationCellTitlePassword),
        BaseCellModel(withTitle: TextConstants.registrationCellInitialTextReFillPassword,
                      initialText: TextConstants.registrationCellInitialTextReFillPassword)]
    }
    
    func getModels() -> [BaseCellModel] {
        return models
    }
    
    func configurateModel(forIndex index: Int, withValue value: String) {
        let model = models[index]
        let newModel = BaseCellModel(withTitle: model.title, initialText: value)//inputText = value
        models[index] = newModel
        debugPrint("models are ", self.models)
    }
    
}

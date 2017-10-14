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
    var gsmModels: [GSMCodeModel]!
    
    var userRegistrationInfo: RegistrationUserInfoModel!
    
    init() {
        models = [BaseCellModel(withTitle: TextConstants.registrationCellTitleEmail,
                                initialText: TextConstants.registrationCellPlaceholderEmail),
        BaseCellModel(withTitle: TextConstants.registrationCellTitleGSMNumber,
                      initialText: ""),
        BaseCellModel(withTitle: TextConstants.registrationCellTitlePassword,
                      initialText:TextConstants.registrationCellPlaceholderPassword),
        BaseCellModel(withTitle: TextConstants.registrationCellTitleReEnterPassword,
                      initialText: TextConstants.registrationCellPlaceholderReFillPassword)]
    }
    
    func getModels() -> [BaseCellModel] {
        return models
    }
    
    func configurateModel(forIndex index: Int, withValue value: String) {
        let model = models[index]
        let newModel = BaseCellModel(withTitle: model.title, initialText: value)
        models[index] = newModel
    }
}

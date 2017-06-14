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
    let titles = ["E-Mail", "GSM Number", "Password", "Re-Enter Password"]//TODO: LOCALISE!
    let initialTexts = ["   You have to fill in your mail", "", "   You have to fill in a password", "  You have to fill in a password"]//TODO: Localise as well
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
